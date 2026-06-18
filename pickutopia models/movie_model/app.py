import re
import random
import threading
import traceback
import numpy as np
import pandas as pd
from flask import Flask, request, jsonify
from flask_cors import CORS
from transformers import pipeline
from spellchecker import SpellChecker
from rapidfuzz import process, fuzz
from sklearn.metrics.pairwise import cosine_similarity
from pyngrok import ngrok, conf

app = Flask(__name__)
CORS(app)

# ─────────────────────────────────────────────
#  NGROK CONFIGURATION  ← put your values here
# ─────────────────────────────────────────────
NGROK_AUTH_TOKEN = "3EMkzIh1D5Vc5cNHfOrlNOhpZgK_6xcANzBGLc4pCGefajsxg"    # e.g. "2abc123xyz..."
NGROK_DOMAIN     = "iphone-footnote-tiger.ngrok-free.dev"         # e.g. "my-movies-bot.ngrok-free.app"
FLASK_PORT       = 5004
# ─────────────────────────────────────────────

INTENTS = {
    "greeting": {
        "patterns": [r"hi|hello|hey|good morning|good evening|how are you|how are you doing"],
        "responses": [
            "Hello! How can I help you today?",
            "Hi there! Ready for movie recommendations?",
            "Hey, hope you are doing well",
            "Hey, are you ready to watch new movies today",
        ],
    },
    "leaving": {
        "patterns": [r"bye|goodbye|exit|quit|see you"],
        "responses": ["Goodbye! Happy watching!", "See you later!"],
    },
    "services": {
        "patterns": [r"what can you do|service|help"],
        "responses": [
            "I can recommend movies! Just ask for recommendations and mention a movie you like.",
            "I am here to help you find new movies",
        ],
    },
    "recommendation": {
        "patterns": [r"recommend|suggest|movies like|a movie like"],
    },
    "non_related": {
        "responses": [
            "Hmm, I'm not sure about that. Let's stick to movie recommendations!",
            "I am not programmed to answer these questions",
        ]
    },
}

# ── Data & Models ──────────────────────────────────────────────────────────────
df            = pd.read_csv("movie_profile.csv")
embeddings_df = pd.read_csv("final_movie_embeddings.csv")
embeddings    = embeddings_df.iloc[:, 1:].values

EXCLUDED_TITLES = {"movie movie"}
STOP_WORDS      = {"a", "an", "the", "and", "or", "like", "i", "want"}

spell               = SpellChecker(language="en", case_sensitive=False)
custom_movie_titles = {title for title in df["title"]}
spell.word_frequency.load_words(custom_movie_titles)

title_lower_to_original = {title.lower(): title for title in df["title"]}
MOVIE_DATABASE          = list(title_lower_to_original.keys())

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
        # ✅ FIX 1: guard for intents without "patterns" key → prevents KeyError
        if "patterns" not in data:
            continue
        for pattern in data["patterns"]:
            if re.search(pattern, cleaned):
                return intent
    return "non_related"


def correct_spelling(query: str) -> str:
    words = query.split()
    corrected_words = []
    for word in words:
        if word.lower() in [t.lower() for t in custom_movie_titles]:
            original = next(t for t in custom_movie_titles if t.lower() == word.lower())
            corrected_words.append(original)
        else:
            # ✅ FIX 2: spell.correction() can return None → AttributeError on .title()/.upper()
            corrected = spell.correction(word.lower())
            if corrected is None:
                corrected = word.lower()
            if word.istitle():
                corrected = corrected.title()
            elif word.isupper():
                corrected = corrected.upper()
            corrected_words.append(corrected)
    return " ".join(corrected_words)


def generate_ngrams(words: list, max_n: int = 5) -> list:
    ngrams = []
    for n in range(1, max_n + 1):
        for i in range(len(words) - n + 1):
            ngrams.append(" ".join(words[i : i + n]).lower())
    return ngrams


def extract_movie_titles(query: str) -> str:
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

    validated = []
    for candidate in sorted(filtered, key=lambda x: -len(x)):
        match, score, _ = process.extractOne(candidate, MOVIE_DATABASE, scorer=fuzz.WRatio)
        if score > 90 and match not in EXCLUDED_TITLES:
            validated.append(title_lower_to_original[match])
            break

    return validated[0] if validated else ""


def find_similar_movies(movie_index: int) -> list:
    """Cosine similarity with NaN-row filtering for safety."""
    input_embedding = embeddings[movie_index]

    # ✅ FIX 3: filter NaN rows before similarity computation → prevents silent errors
    valid_mask       = ~np.isnan(embeddings).any(axis=1)
    valid_embeddings = embeddings[valid_mask]
    valid_indices    = np.where(valid_mask)[0]

    similarities = cosine_similarity(
        input_embedding.reshape(1, -1), valid_embeddings
    ).flatten()

    similar_movies = []
    for sim_idx in similarities.argsort()[::-1]:
        original_idx = valid_indices[sim_idx]
        if original_idx != movie_index and len(similar_movies) < 5:
            similar_movies.append(df.iloc[original_idx]["title"])

    return similar_movies


# ── Route ──────────────────────────────────────────────────────────────────────

@app.route("/movies_chatbot", methods=["POST"])
def chat_endpoint():
    try:
        data       = request.json
        user_input = data.get("message")

        if not user_input:
            return jsonify({"error": "No message provided"}), 400

        corrected_input = correct_spelling(user_input)
        cleaned_input   = preprocess(corrected_input)
        intent          = detect_intent(cleaned_input)

        print(f"User input     : {user_input}")
        print(f"Corrected input: {corrected_input}")
        print(f"Detected intent: {intent}")

        if intent == "greeting":
            response = random.choice(INTENTS["greeting"]["responses"])

        elif intent == "leaving":
            response = random.choice(INTENTS["leaving"]["responses"])

        elif intent == "services":
            response = random.choice(INTENTS["services"]["responses"])

        elif intent == "recommendation":
            movie_title = extract_movie_titles(corrected_input)
            if not movie_title:
                response = "Could not identify a movie title in your request."
            else:
                try:
                    index         = df[df["title"] == movie_title].index[0]
                    similar_movies = find_similar_movies(index)

                    if similar_movies:
                        response = {"movie": movie_title, "recommendations": similar_movies}
                    else:
                        response = "Sorry, I couldn't find any recommendations for that movie."

                except IndexError:
                    response = f"Title '{movie_title}' not found in the dataset."
                except Exception as e:
                    traceback.print_exc()
                    response = f"Error processing recommendation: {str(e)}"

        else:
            response = random.choice(INTENTS["non_related"]["responses"])

        return jsonify({"response": response})

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500


# ── ngrok tunnel + Flask startup ───────────────────────────────────────────────

def start_ngrok():
    conf.get_default().auth_token = NGROK_AUTH_TOKEN

    tunnel = ngrok.connect(
        addr=FLASK_PORT,
        domain=NGROK_DOMAIN,
        proto="http",
    )

    public_url = tunnel.public_url
    print("\n" + "=" * 60)
    print("  ✅  ngrok tunnel is LIVE")
    print(f"  🌐  Public URL  : {public_url}")
    print(f"  📱  Flutter URL : {public_url}/movies_chatbot")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    ngrok_thread = threading.Thread(target=start_ngrok, daemon=True)
    ngrok_thread.start()
    ngrok_thread.join()

    # ✅ FIX 4: debug=False — debug=True spawns 2 processes → ngrok tunnel opened twice
    app.run(host="0.0.0.0", port=FLASK_PORT, debug=False)