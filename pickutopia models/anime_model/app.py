import re
import random
import threading
from flask import Flask, request, jsonify
from transformers import pipeline
from spellchecker import SpellChecker
from rapidfuzz import process, fuzz
import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from pyngrok import ngrok, conf

app = Flask(__name__)

# ─────────────────────────────────────────────
#  NGROK CONFIGURATION  ← put your values here
# ─────────────────────────────────────────────
NGROK_AUTH_TOKEN = "3ELovLWhVVH8hdNr8MedIndPC4J_3j1JsTna4GVTvYPHcMgEt"   # e.g. "2abc123xyz..."
NGROK_DOMAIN     = "gullible-seltzer-morbidly.ngrok-free.dev"        # e.g. "my-anime-bot.ngrok-free.app"
FLASK_PORT       = 5002
# ─────────────────────────────────────────────

INTENTS = {
    "greeting": {
        "patterns": [r"hi|hello|hey|good morning|good evening|how are you|how are you doing"],
        "responses": [
            "Hello! How can I help you today?",
            "Hi there! Ready for anime recommendations?",
            "Hey, hope you are doing well",
            "Hey, are you ready to watch new animes today",
        ],
    },
    "leaving": {
        "patterns": [r"bye|goodbye|exit|quit|see you"],
        "responses": ["Goodbye! Happy watching!", "See you later!"],
    },
    "services": {
        "patterns": [r"what can you do|service|help"],
        "responses": [
            "I can recommend animes! Just ask for recommendations and mention an anime you like.",
            "I am here to help you find new animes",
        ],
    },
    "recommendation": {
        "patterns": [r"recommend|suggest|animes like|a anime like"],
    },
    "non_related": {
        "responses": [
            "Hmm, I'm not sure about that. Let's stick to anime recommendations!",
            "I am not programmed to answer these questions",
        ]
    },
}

# ── Data & Models ──────────────────────────────────────────────────────────────
df             = pd.read_csv("animes_profile.csv")
embeddings_df  = pd.read_csv("final_anime_embeddings.csv")
embeddings     = embeddings_df.iloc[:, 1:].values

EXCLUDED_TITLES = {"movie movie"}
STOP_WORDS      = {"a", "an", "the", "and", "or", "like", "i", "want"}

spell               = SpellChecker(language="en", case_sensitive=False)
custom_anime_titles = {title for title in df["title"]}
spell.word_frequency.load_words(custom_anime_titles)

ner_pipeline = pipeline(
    "ner",
    model="dslim/bert-base-NER",
    tokenizer="dslim/bert-base-NER",
    aggregation_strategy="simple",
)

# ── Helpers ────────────────────────────────────────────────────────────────────

def preprocess(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[^\w\s]", "", text)
    return text


def detect_intent(user_input: str) -> str:
    cleaned = preprocess(user_input)
    for intent, data in INTENTS.items():
        if intent == "non_related":
            continue
        for pattern in data["patterns"]:
            if re.search(pattern, cleaned):
                return intent
    return "non_related"


def generate_ngrams(words: list, max_n: int = 5) -> list:
    ngrams = []
    for n in range(1, max_n + 1):
        for i in range(len(words) - n + 1):
            ngrams.append(" ".join(words[i : i + n]).lower())
    return ngrams


def correct_spelling(query: str) -> str:
    words = query.split()
    corrected_words = []
    for word in words:
        if word.lower() in [t.lower() for t in custom_anime_titles]:
            original = next(t for t in custom_anime_titles if t.lower() == word.lower())
            corrected_words.append(original)
        else:
            corrected = spell.correction(word.lower()) or word
            if word.istitle():
                corrected = corrected.title()
            elif word.isupper():
                corrected = corrected.upper()
            corrected_words.append(corrected)
    return " ".join(corrected_words)


def extract_anime_titles(query: str) -> str:
    corrected_query = correct_spelling(query)

    results        = ner_pipeline(corrected_query)
    ner_candidates = [
        entity["word"].lower()
        for entity in results
        if entity["entity_group"] in ["ORG", "MISC"]
    ]

    corrected_words  = corrected_query.split()
    ngram_candidates = generate_ngrams(corrected_words)

    all_candidates = list(set(ner_candidates + ngram_candidates))

    filtered = []
    for candidate in all_candidates:
        if " " in candidate:
            filtered.append(candidate)
        elif len(candidate) > 2 and candidate not in STOP_WORDS:
            filtered.append(candidate)

    title_lower_to_original = {title.lower(): title for title in df["title"]}
    anime_database          = list(title_lower_to_original.keys())

    validated = []
    for candidate in sorted(filtered, key=lambda x: -len(x)):
        match, score, _ = process.extractOne(candidate, anime_database, scorer=fuzz.WRatio)
        if score > 90 and match not in EXCLUDED_TITLES:
            validated.append(title_lower_to_original[match])
            break

    return validated[0] if validated else ""


# ── Route ──────────────────────────────────────────────────────────────────────

@app.route("/animes_chatbot", methods=["POST"])
def chat_endpoint():
    data       = request.json
    user_input = data.get("message")

    if not user_input:
        return jsonify({"error": "No message provided"}), 400

    corrected_input = correct_spelling(user_input)
    cleaned_input   = preprocess(corrected_input)
    intent          = detect_intent(cleaned_input)

    if intent == "greeting":
        response = random.choice(INTENTS["greeting"]["responses"])

    elif intent == "leaving":
        response = random.choice(INTENTS["leaving"]["responses"])

    elif intent == "services":
        response = random.choice(INTENTS["services"]["responses"])

    elif intent == "recommendation":
        anime_title = extract_anime_titles(corrected_input)
        if not anime_title:
            response = "Could not identify an anime title in your request."
        else:
            try:
                index           = df[df["title"] == anime_title].index[0]
                input_embedding = embeddings[index]
                similarities    = cosine_similarity(
                    input_embedding.reshape(1, -1), embeddings
                ).flatten()
                top_indices  = similarities.argsort()[::-1][1:6]
                similar_anime = [df.iloc[idx]["title"] for idx in top_indices]
                response = {"anime": anime_title, "recommendations": similar_anime}
            except IndexError:
                response = f"Title '{anime_title}' not found in the dataset."

    else:
        response = random.choice(INTENTS["non_related"]["responses"])

    return jsonify({"response": response})


# ── ngrok tunnel + Flask startup ───────────────────────────────────────────────

def start_ngrok():
    """Authenticate, open a tunnel on the custom domain, and print the public URL."""
    conf.get_default().auth_token = NGROK_AUTH_TOKEN

    tunnel = ngrok.connect(
        addr=FLASK_PORT,
        domain=NGROK_DOMAIN,   # reserved static domain (free/paid)
        proto="http",
    )

    public_url = tunnel.public_url
    print("\n" + "=" * 60)
    print("  ✅  ngrok tunnel is LIVE")
    print(f"  🌐  Public URL  : {public_url}")
    print(f"  📱  Flutter URL : {public_url}/animes_chatbot")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    # Start ngrok in a background thread so Flask can start immediately after
    ngrok_thread = threading.Thread(target=start_ngrok, daemon=True)
    ngrok_thread.start()
    ngrok_thread.join()   

    app.run(host="0.0.0.0", port=FLASK_PORT)