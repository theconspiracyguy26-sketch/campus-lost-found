# model-server/utils.py
import io
from PIL import Image
import numpy as np
import torch
from transformers import BlipProcessor, BlipForConditionalGeneration, CLIPProcessor, CLIPModel

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

def load_models():
    blip_processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-base")
    blip_model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-base").to(DEVICE)

    clip_model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32").to(DEVICE)
    clip_processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")

    return {
        "blip_processor": blip_processor,
        "blip_model": blip_model,
        "clip_processor": clip_processor,
        "clip_model": clip_model
    }

def caption_image_bytes(image_bytes, models):
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    inputs = models["blip_processor"](image, return_tensors="pt").to(DEVICE)
    out = models["blip_model"].generate(**inputs)
    caption = models["blip_processor"].decode(out[0], skip_special_tokens=True)
    return caption

def embed_image_bytes(image_bytes, models):
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    inputs = models["clip_processor"](images=image, return_tensors="pt").to(DEVICE)
    with torch.no_grad():
        image_embeds = models["clip_model"].get_image_features(**inputs)
    image_embeds = image_embeds / image_embeds.norm(p=2, dim=-1, keepdim=True)
    return image_embeds.cpu().numpy()[0].astype(float)

def embed_text(text, models):
    inputs = models["clip_processor"](text=[text], return_tensors="pt", padding=True).to(DEVICE)
    with torch.no_grad():
        text_embeds = models["clip_model"].get_text_features(**inputs)
    text_embeds = text_embeds / text_embeds.norm(p=2, dim=-1, keepdim=True)
    return text_embeds.cpu().numpy()[0].astype(float)

def cosine_sim(a, b):
    a = a / (np.linalg.norm(a) + 1e-12)
    b = b / (np.linalg.norm(b) + 1e-12)
    return float(np.dot(a, b))
