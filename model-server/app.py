# model-server/app.py
import os
import json
from flask import Flask, request, jsonify
from utils import load_models, caption_image_bytes, embed_image_bytes, embed_text, cosine_sim
from dotenv import load_dotenv
import numpy as np

load_dotenv()
app = Flask(__name__)
models = load_models()

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/caption", methods=["POST"])
def caption():
    if "file" not in request.files:
        return jsonify({"error": "file required"}), 400
    f = request.files["file"].read()
    caption = caption_image_bytes(f, models)
    return jsonify({"caption": caption})

@app.route("/embed/image", methods=["POST"])
def embed_image():
    if "file" not in request.files:
        return jsonify({"error": "file required"}), 400
    f = request.files["file"].read()
    emb = embed_image_bytes(f, models)
    return jsonify({"embedding": emb.tolist()})

@app.route("/embed/text", methods=["POST"])
def embed_text_route():
    data = request.get_json(force=True)
    if not data or "text" not in data:
        return jsonify({"error":"text required"}), 400
    emb = embed_text(data["text"], models)
    return jsonify({"embedding": emb.tolist()})

# match endpoint expects payload: {embedding: [...], candidates: [{id, embedding}], topk: int}
@app.route("/match", methods=["POST"])
def match():
    j = request.get_json(force=True)
    embedding = j.get("embedding")
    candidates = j.get("candidates", [])
    topk = int(j.get("topk", 5))
    if embedding is None:
        return jsonify({"error": "embedding required"}), 400
    emb = np.array(embedding, dtype=float)
    results = []
    for c in candidates:
        cemb = np.array(c["embedding"], dtype=float)
        score = cosine_sim(emb, cemb)
        results.append({"id": c["id"], "score": float(score)})
    results = sorted(results, key=lambda r: r["score"], reverse=True)[:topk]
    return jsonify({"matches": results})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
