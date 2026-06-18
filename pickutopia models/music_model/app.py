import os
import re
import traceback
import random
import threading
import requests

from flask import Flask, request, jsonify
from flask_cors import CORS
from pyngrok import ngrok, conf

# ── Flask setup ────────────────────────────────────────────────────────────────
app = Flask(__name__)
CORS(app, resources={
    r"/*": {
        "origins": "*",
        "methods": ["GET", "POST"],
        "allow_headers": ["Content-Type", "ngrok-skip-browser-warning"],
    }
})

# ── Configuration ──────────────────────────────────────────────────────────────
# Recommended: set these in Colab / environment instead of hardcoding secrets.
LASTFM_API_KEY = "04ae9e2d58863bd2f8378c42bc14606d"
NGROK_AUTH_TOKEN = "3EMmgsQDsYZQbf3vD94OuOoV4Qf_4shsJjK6c3yS8kmPZR1aX"
NGROK_DOMAIN = "footbath-previous-divisive.ngrok-free.dev"
FLASK_PORT = 8080

LASTFM_BASE_URL = "https://ws.audioscrobbler.com/2.0/"

# ── Error handlers ─────────────────────────────────────────────────────────────
@app.errorhandler(404)
def not_found_error(error):
    return jsonify({
        "status": "error",
        "error": "Not Found",
        "message": "The requested URL was not found. Available endpoints: /recommendations (GET/POST), /test (GET)",
        "documentation": "Visit the root path (/) for API documentation",
    }), 404


@app.errorhandler(405)
def method_not_allowed_error(error):
    return jsonify({
        "status": "error",
        "error": "Method Not Allowed",
        "message": f"The method {request.method} is not allowed for this endpoint",
        "allowed_methods": getattr(error, "valid_methods", None),
    }), 405


# ── Last.fm helpers ────────────────────────────────────────────────────────────
def lastfm_request(params: dict) -> dict:
    if not LASTFM_API_KEY or LASTFM_API_KEY == "PUT_YOUR_LASTFM_API_KEY_HERE":
        raise ValueError("Missing Last.fm API key. Set LASTFM_API_KEY first.")

    params = {
        **params,
        "api_key": LASTFM_API_KEY,
        "format": "json",
    }

    response = requests.get(LASTFM_BASE_URL, params=params, timeout=15)
    response.raise_for_status()

    data = response.json()
    if "error" in data:
        raise RuntimeError(data.get("message", "Last.fm API error"))

    return data


def force_list(value):
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def get_best_image(images):
    images = force_list(images)
    for size in ["extralarge", "large", "medium", "small"]:
        for image in images:
            if isinstance(image, dict) and image.get("size") == size and image.get("#text"):
                return image.get("#text")
    return None


def parse_artist_name(artist_data):
    if isinstance(artist_data, dict):
        return artist_data.get("name", "").strip()
    return str(artist_data or "").strip()


def format_track(track: dict) -> dict | None:
    name = (track.get("name") or "").strip()
    artist = parse_artist_name(track.get("artist"))

    if not name or not artist:
        return None

    return {
        "name": name,
        "artist": artist,
        "preview_url": None,  # Last.fm does not provide Spotify preview URLs
        "spotify_url": None,  # kept only so your old Flutter model will not break
        "lastfm_url": track.get("url"),
        "image_url": get_best_image(track.get("image")),
    }


def dedupe_tracks(tracks: list[dict], limit: int = 5, exclude: tuple[str, str] | None = None) -> list[dict]:
    recommendations = []
    seen = set()

    exclude_name = exclude[0].lower().strip() if exclude else ""
    exclude_artist = exclude[1].lower().strip() if exclude else ""

    for track in tracks:
        formatted = format_track(track)
        if not formatted:
            continue

        name_lower = formatted["name"].lower().strip()
        artist_lower = formatted["artist"].lower().strip()

        if exclude and name_lower == exclude_name and artist_lower == exclude_artist:
            continue

        key = f"{name_lower}::{artist_lower}"
        if key in seen:
            continue

        seen.add(key)
        recommendations.append(formatted)

        if len(recommendations) == limit:
            break

    return recommendations


# ── Last.fm API features ───────────────────────────────────────────────────────
def search_track_by_name(track_name: str) -> dict | None:
    data = lastfm_request({
        "method": "track.search",
        "track": track_name,
        "limit": 10,
    })

    tracks = (
        data.get("results", {})
        .get("trackmatches", {})
        .get("track", [])
    )

    tracks = force_list(tracks)
    valid_tracks = [track for track in tracks if track.get("name") and track.get("artist")]

    if not valid_tracks:
        return None

    best_track = valid_tracks[0]

    return {
        "name": best_track.get("name", "").strip(),
        "artist": best_track.get("artist", "").strip(),
        "url": best_track.get("url"),
        "image_url": get_best_image(best_track.get("image")),
    }


def search_artist_by_name(artist_name: str) -> dict | None:
    data = lastfm_request({
        "method": "artist.search",
        "artist": artist_name,
        "limit": 10,
    })

    artists = (
        data.get("results", {})
        .get("artistmatches", {})
        .get("artist", [])
    )

    artists = force_list(artists)
    valid_artists = [artist for artist in artists if artist.get("name")]

    if not valid_artists:
        return None

    best_artist = valid_artists[0]

    return {
        "name": best_artist.get("name", "").strip(),
        "url": best_artist.get("url"),
        "image_url": get_best_image(best_artist.get("image")),
    }


def get_similar_tracks(track_query: str, limit: int = 5) -> list[dict]:
    found_track = search_track_by_name(track_query)
    if not found_track:
        return []

    data = lastfm_request({
        "method": "track.getsimilar",
        "track": found_track["name"],
        "artist": found_track["artist"],
        "autocorrect": 1,
        "limit": limit + 10,
    })

    similar_tracks = (
        data.get("similartracks", {})
        .get("track", [])
    )

    similar_tracks = force_list(similar_tracks)

    return dedupe_tracks(
        similar_tracks,
        limit=limit,
        exclude=(found_track["name"], found_track["artist"]),
    )


def get_artist_top_tracks(artist_query: str, limit: int = 5) -> list[dict]:
    found_artist = search_artist_by_name(artist_query)
    artist_name = found_artist["name"] if found_artist else artist_query

    data = lastfm_request({
        "method": "artist.gettoptracks",
        "artist": artist_name,
        "autocorrect": 1,
        "limit": limit + 5,
    })

    tracks = (
        data.get("toptracks", {})
        .get("track", [])
    )

    return dedupe_tracks(force_list(tracks), limit=limit)


def get_tag_top_tracks(tag: str, limit: int = 5) -> list[dict]:
    data = lastfm_request({
        "method": "tag.gettoptracks",
        "tag": tag,
        "limit": limit + 10,
    })

    tracks = (
        data.get("tracks", {})
        .get("track", [])
    )

    return dedupe_tracks(force_list(tracks), limit=limit)


def get_similar_artists(artist_query: str, limit: int = 5) -> list[dict]:
    found_artist = search_artist_by_name(artist_query)
    artist_name = found_artist["name"] if found_artist else artist_query

    data = lastfm_request({
        "method": "artist.getsimilar",
        "artist": artist_name,
        "autocorrect": 1,
        "limit": limit + 5,
    })

    artists = (
        data.get("similarartists", {})
        .get("artist", [])
    )

    results = []
    seen = set()

    for artist in force_list(artists):
        name = (artist.get("name") or "").strip()
        if not name:
            continue

        key = name.lower()
        if key in seen or key == artist_name.lower():
            continue

        seen.add(key)
        results.append({
            "name": name,
            "artist": "Similar artist",
            "preview_url": None,
            "spotify_url": None,
            "lastfm_url": artist.get("url"),
            "image_url": get_best_image(artist.get("image")),
            "type": "artist",
        })

        if len(results) == limit:
            break

    return results



# ── Small talk / general chatbot responses ────────────────────────────────────
SMALL_TALK_RESPONSES = {
    "wellbeing": [
        "I'm doing great, thanks for asking! 🎵 Tell me a song you like and I will recommend similar music.",
        "I'm good! Ready to help you discover new songs.",
        "Doing well! What kind of music are you in the mood for today?",
    ],
    "thanks": [
        "You're welcome! 🎧",
        "Anytime! Send me another song when you want more recommendations.",
        "Glad to help!",
    ],
    "identity": [
        "I'm your music discovery assistant. I can recommend songs, artists, moods, and top tracks using Last.fm.",
        "I'm a Last.fm-powered music chatbot built to help you find songs you may enjoy.",
    ],
    "bot_name": [
        "You can call me your Music Assistant 🎵",
        "I'm your music recommendation chatbot.",
    ],
    "capabilities": [
        "I can help you with:\n"
        "🎵 Songs similar to a track\n"
        "🎸 Artists similar to another artist\n"
        "🎧 Mood-based recommendations\n"
        "🌟 Top tracks for an artist\n"
        "Try: \"Find songs like Blinding Lights\"",
    ],
    "positive": [
        "Nice! 😄 Want me to recommend something based on your mood?",
        "Great! Send me a song name and I will find similar music.",
    ],
    "negative": [
        "Sorry to hear that. Maybe some music can help. Try asking for relaxing or sad songs.",
        "I hope your day gets better. I can recommend calm, happy, or emotional songs.",
    ],
    "joke": [
        "Why did the musician bring a ladder? To reach the high notes 🎶",
        "Why did the song go to school? To improve its notes 🎵",
    ],
    "unknown_general": [
        "I'm mainly focused on music recommendations. Try asking me for songs, artists, moods, or top tracks.",
        "I may not be able to answer that, but I can help you discover music!",
    ],
}


def normalize_message(message: str) -> str:
    message = message.lower().strip()
    message = re.sub(r"[^\w\s']", " ", message)
    return re.sub(r"\s+", " ", message).strip()


def phrase_exists(message: str, phrases: list[str]) -> bool:
    normalized = normalize_message(message)
    for phrase in phrases:
        escaped = re.escape(phrase.lower())
        if re.search(rf"(^|\s){escaped}($|\s)", normalized):
            return True
    return False


def detect_small_talk(message: str) -> dict | None:
    normalized = normalize_message(message)

    if phrase_exists(normalized, [
        "how are you", "how are you doing", "how is it going",
        "how do you do", "are you ok", "are you okay", "what's up", "whats up"
    ]):
        return {
            "type": "smalltalk",
            "intent": "wellbeing",
            "message": random.choice(SMALL_TALK_RESPONSES["wellbeing"]),
        }

    if phrase_exists(normalized, [
        "thanks", "thank you", "thx", "appreciate it", "thank u"
    ]):
        return {
            "type": "smalltalk",
            "intent": "thanks",
            "message": random.choice(SMALL_TALK_RESPONSES["thanks"]),
        }

    if phrase_exists(normalized, [
        "who are you", "what are you", "tell me about yourself"
    ]):
        return {
            "type": "smalltalk",
            "intent": "identity",
            "message": random.choice(SMALL_TALK_RESPONSES["identity"]),
        }

    if phrase_exists(normalized, [
        "what is your name", "what's your name", "your name"
    ]):
        return {
            "type": "smalltalk",
            "intent": "bot_name",
            "message": random.choice(SMALL_TALK_RESPONSES["bot_name"]),
        }

    if phrase_exists(normalized, [
        "what can you do", "what do you do", "features", "commands",
        "can you help me", "how can you help me"
    ]):
        return {
            "type": "help",
            "intent": "capabilities",
            "message": random.choice(SMALL_TALK_RESPONSES["capabilities"]),
        }

    if phrase_exists(normalized, [
        "tell me a joke", "joke", "make me laugh"
    ]):
        return {
            "type": "smalltalk",
            "intent": "joke",
            "message": random.choice(SMALL_TALK_RESPONSES["joke"]),
        }

    if phrase_exists(normalized, [
        "i am good", "i'm good", "i am fine", "i'm fine",
        "great", "awesome", "nice", "cool"
    ]):
        return {
            "type": "smalltalk",
            "intent": "positive",
            "message": random.choice(SMALL_TALK_RESPONSES["positive"]),
        }

    if phrase_exists(normalized, [
        "i am bad", "i'm bad", "not good", "not fine",
        "i feel bad", "i am tired", "i'm tired"
    ]):
        return {
            "type": "smalltalk",
            "intent": "negative",
            "message": random.choice(SMALL_TALK_RESPONSES["negative"]),
        }

    return None

# ── Chat message processing, very close to your old Spotify version ────────────
def clean_reference(text: str) -> str:
    text = text.strip()
    text = re.sub(r"^(please|pls)\s+", "", text, flags=re.IGNORECASE)
    text = re.sub(r"\s+(please|pls)$", "", text, flags=re.IGNORECASE)
    text = text.strip(" \"'“”‘’?.!")
    return text.strip()


def extract_artist_for_top_tracks(message: str) -> str:
    message = message.strip().lower()

    patterns = [
        r"(?:top tracks|top songs|popular songs|most popular songs|best songs)\s+(?:by|from|for)\s+(?P<artist>.+)",
        r"(?:what are|show me|give me|list)?\s*(?P<artist>.+?)(?:'s|’s)?\s+(?:top tracks|top songs|popular songs|most popular songs|best songs)",
    ]

    for pattern in patterns:
        match = re.search(pattern, message, flags=re.IGNORECASE)
        if match:
            return clean_reference(match.group("artist"))

    cleaned = re.sub(
        r"\b(what are|show me|give me|list|top tracks|top songs|popular songs|most popular songs|best songs|by|from|for)\b",
        " ",
        message,
        flags=re.IGNORECASE,
    )
    return clean_reference(re.sub(r"\s+", " ", cleaned))


def extract_artist_for_similarity(message: str) -> str:
    patterns = [
        r"(?:artists?|bands?)\s+(?:similar to|like)\s+(?P<artist>.+)",
        r"similar\s+(?:artists?|bands?)\s+(?:to|like)\s+(?P<artist>.+)",
        r"(?:show me|find|recommend|suggest)?\s*(?:\w+\s+)?(?:artists?|bands?)\s+similar to\s+(?P<artist>.+)",
    ]

    for pattern in patterns:
        match = re.search(pattern, message, flags=re.IGNORECASE)
        if match:
            return clean_reference(match.group("artist"))

    return clean_reference(message)


def extract_track_reference(message: str) -> str:
    patterns = [
        r"(?:songs?|tracks?|music)\s+like\s+(?P<track>.+)",
        r"similar\s+to\s+(?P<track>.+)",
        r"same\s+as\s+(?P<track>.+)",
        r"sounds?\s+like\s+(?P<track>.+)",
        r"reminds me of\s+(?P<track>.+)",
        r"(?:find|recommend|suggest)(?:\s+me)?(?:\s+some)?(?:\s+songs?|\s+tracks?|\s+music)?(?:\s+like)?\s+(?P<track>.+)",
    ]

    for pattern in patterns:
        match = re.search(pattern, message, flags=re.IGNORECASE)
        if match:
            return clean_reference(match.group("track"))

    return clean_reference(message)


def process_chat_message(message: str) -> dict:
    original_message = message.strip()
    message = message.lower().strip()

    if phrase_exists(message, ["hello", "hi", "hey", "howdy", "hola", "good morning", "good evening"]):
        return {
            "type": "greeting",
            "message": "Hello! 🎵 I'm your music discovery assistant! I can help you find new songs, explore artists, or discover music based on your mood. What would you like to hear today?"
        }

    if phrase_exists(message, ["bye", "goodbye", "see you", "later", "farewell", "ciao", "adios", "see ya", "take care", "good night"]):
        return {
            "type": "farewell",
            "message": "Goodbye! 👋 Hope you discover great music. Come back anytime for more recommendations!"
        }

    if "help" in message:
        return {
            "type": "help",
            "message": "I can help you with:\n"
                       "🎵 Music recommendations (e.g. \"Find songs like Bohemian Rhapsody\")\n"
                       "🎸 Artist discoveries (e.g. \"Show me rock bands similar to Queen\")\n"
                       "🎧 Mood-based suggestions (e.g. \"I need some upbeat music for working out\")\n"
                       "🌟 Top tracks (e.g. \"What are Taylor Swift's most popular songs?\")\n"
                       "Just tell me what you're looking for!"
        }

    small_talk = detect_small_talk(original_message)
    if small_talk:
        return small_talk

    # Top tracks must be checked before the general artist branch.
    top_track_patterns = [
        "top tracks", "top songs", "popular songs", "most popular songs", "best songs"
    ]
    if any(pattern in message for pattern in top_track_patterns):
        artist = extract_artist_for_top_tracks(original_message)
        return {
            "type": "recommendations",
            "mode": "artist_top_tracks",
            "query": artist,
            "message": f"Here are {artist.title()}'s top tracks:"
        }

    # Artist / band discovery.
    artist_similarity_patterns = [
        "similar artists", "similar bands", "artists like", "bands like",
        "artist like", "band like", "bands similar to", "artists similar to",
        "band similar to", "artist similar to"
    ]
    if any(pattern in message for pattern in artist_similarity_patterns):
        artist = extract_artist_for_similarity(original_message)
        return {
            "type": "recommendations",
            "mode": "similar_artists",
            "query": artist,
            "message": f"Here are some artists similar to {artist.title()}:"
        }

    mood_keywords = {
        "happy": ["happy", "cheerful", "upbeat", "joyful", "energetic"],
        "sad": ["sad", "melancholy", "emotional", "heartbreak"],
        "relaxed": ["relaxing", "calm", "peaceful", "chill", "meditation"],
        "party": ["party", "dance", "club", "celebration"],
        "workout": ["workout", "exercise", "gym", "running", "training"],
    }

    mood_queries = {
        "happy": "happy",
        "sad": "sad",
        "relaxed": "chillout",
        "party": "dance",
        "workout": "workout",
    }

    for mood, keywords in mood_keywords.items():
        if any(keyword in message for keyword in keywords):
            return {
                "type": "recommendations",
                "mode": "tag_top_tracks",
                "query": mood_queries[mood],
                "message": f"Here are some {mood} songs that might match your mood:"
            }

    # Artist-based top tracks, similar to your old Spotify fallback behavior.
    if any(word in message for word in [" by ", " from ", "artist", "band"]):
        artist = original_message
        for separator in [" by ", " from "]:
            if separator in message:
                artist = original_message.lower().split(separator, 1)[1]
                break

        artist = clean_reference(artist)
        artist = re.sub(r"\b(show me|recommend|suggest|songs|tracks|music|artist|band|by|from)\b", " ", artist, flags=re.IGNORECASE)
        artist = clean_reference(re.sub(r"\s+", " ", artist))

        return {
            "type": "recommendations",
            "mode": "artist_top_tracks",
            "query": artist,
            "message": "Here are some recommendations based on that artist:"
        }

    similarity_patterns = [
        "like", "similar to", "same as", "sounds like", "reminds me of",
        "similar songs", "songs like", "music like", "tracks like"
    ]

    if any(pattern in message for pattern in similarity_patterns):
        reference = extract_track_reference(original_message)
        return {
            "type": "recommendations",
            "mode": "track_similarity",
            "query": reference,
            "message": f"Here are some songs similar to \"{reference.title()}\":"
        }

    # Default: treat plain user text as a track name, like "Blinding Lights".
    return {
        "type": "recommendations",
        "mode": "track_similarity",
        "query": clean_reference(original_message),
        "message": "Here are some songs you might enjoy:"
    }


def get_recommendations(processed_query: dict, limit: int = 5) -> list[dict]:
    mode = processed_query.get("mode", "track_similarity")
    query = processed_query.get("query", "").strip()

    if not query:
        return []

    if mode == "artist_top_tracks":
        return get_artist_top_tracks(query, limit=limit)

    if mode == "tag_top_tracks":
        return get_tag_top_tracks(query, limit=limit)

    if mode == "similar_artists":
        return get_similar_artists(query, limit=limit)

    return get_similar_tracks(query, limit=limit)


# ── Routes ─────────────────────────────────────────────────────────────────────
@app.route("/", methods=["GET"])
def index():
    return jsonify({
        "status": "success",
        "message": "Welcome to the Last.fm Music Recommendation API",
        "endpoints": {
            "/recommendations": "GET/POST - Get music recommendations",
            "/test": "GET - Test server and Last.fm connection",
        },
        "examples": [
            {"message": "Find songs like Bohemian Rhapsody"},
            {"message": "Show me rock bands similar to Queen"},
            {"message": "I need some upbeat music for working out"},
            {"message": "What are Taylor Swift's most popular songs?"},
            {"message": "Blinding Ligths"},
            {"message": "How are you?"},
            {"message": "Who are you?"},
            {"message": "Tell me a joke"},
        ]
    })


@app.route("/recommendations", methods=["GET", "POST"])
def recommend():
    if request.method == "GET":
        query = request.args.get("query", "").strip()
        if not query:
            return jsonify({"error": "No query provided"}), 400
    else:
        try:
            if not request.is_json:
                return jsonify({"error": "Content-Type must be application/json"}), 415

            data = request.get_json(force=True)
            if not isinstance(data, dict):
                return jsonify({"error": "Invalid request format"}), 400

            # Supports your old Flutter service: {'query': query}
            # Also supports chatbot/movie-style body: {'message': message}
            query = (data.get("query") or data.get("message") or "").strip()
            if not query:
                return jsonify({"error": "No query/message provided"}), 400
        except Exception:
            return jsonify({"error": "Invalid JSON data"}), 400

    try:
        print("Received recommendation request:", query)

        processed_query = process_chat_message(query)
        print("Processed query:", processed_query)

        if processed_query["type"] in ["greeting", "farewell", "help", "smalltalk"]:
            return jsonify({
                "status": "success",
                "type": processed_query["type"],
                "recommendations": [],
                "message": processed_query.get("message", ""),
            })

        recommendations = get_recommendations(processed_query, limit=5)

        return jsonify({
            "status": "success",
            "type": processed_query.get("type", "recommendations"),
            "mode": processed_query.get("mode", "track_similarity"),
            "query": processed_query.get("query", query),
            "message": processed_query.get("message", "Here are some songs you might enjoy:"),
            "recommendations": recommendations,
        })

    except Exception as e:
        error_trace = traceback.format_exc()
        print(f"Error: {str(e)}\nTraceback: {error_trace}")
        return jsonify({
            "status": "error",
            "error": "Internal server error",
            "message": str(e),
        }), 500


@app.route("/test", methods=["GET"])
def test():
    try:
        data = lastfm_request({
            "method": "track.search",
            "track": "test",
            "limit": 1,
        })

        tracks = (
            data.get("results", {})
            .get("trackmatches", {})
            .get("track", [])
        )

        return jsonify({
            "status": "Server is running",
            "lastfm": "connected",
            "results_found": len(force_list(tracks)),
        })

    except Exception as e:
        return jsonify({
            "status": "error",
            "lastfm": "not connected",
            "details": str(e),
        }), 500


# ── ngrok tunnel + Flask startup ───────────────────────────────────────────────
def start_ngrok():
    if not NGROK_AUTH_TOKEN or NGROK_AUTH_TOKEN == "PUT_YOUR_NGROK_AUTH_TOKEN_HERE":
        print("⚠️ Ngrok auth token is missing. Flask will run locally only.")
        return

    conf.get_default().auth_token = NGROK_AUTH_TOKEN

    if NGROK_DOMAIN:
        tunnel = ngrok.connect(addr=FLASK_PORT, domain=NGROK_DOMAIN, proto="http")
    else:
        tunnel = ngrok.connect(addr=FLASK_PORT, proto="http")

    public_url = tunnel.public_url
    print("\n" + "=" * 60)
    print("✅ ngrok tunnel is LIVE")
    print(f"🌐 Public URL       : {public_url}")
    print(f"📱 Flutter base URL : {public_url}")
    print(f"🎵 Recommendations  : {public_url}/recommendations")
    print(f"🔧 Test endpoint    : {public_url}/test")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    try:
        lastfm_request({
            "method": "track.search",
            "track": "test",
            "limit": 1,
        })
        print("✅ Successfully connected to Last.fm API!")
    except Exception as e:
        print(f"❌ Last.fm connection failed: {e}")

    ngrok_thread = threading.Thread(target=start_ngrok, daemon=True)
    ngrok_thread.start()
    ngrok_thread.join()

    app.run(
        host="0.0.0.0",
        port=FLASK_PORT,
        debug=False,
        threaded=True,
    )
