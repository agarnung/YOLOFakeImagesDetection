from flask import Flask, request, jsonify, send_from_directory, render_template
from PIL import Image
import io
import os
from ultralytics import YOLO
import cv2
import numpy as np

app = Flask(__name__)

# Define paths
MODEL_PATH = "./models/my_model/weights/best.pt"
OUTPUT_DIR = "./output/web"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Load YOLO model
model = YOLO(MODEL_PATH)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/detect", methods=["POST"])
def detect():
    if "image" not in request.files:
        print("🚨 'image' not found in request.files")
        return jsonify({"error": "No image part"}), 400

    file = request.files["image"]
    print(f"📂 Image received: {file.filename}")

    if file.filename == "":
        return jsonify({"error": "No selected image"}), 400
    
    try:
        file_extension = os.path.splitext(file.filename)[-1].lower()
        is_video = file_extension in [".mp4", ".avi", ".mov", ".mkv"]

        if not is_video:
            if file_extension not in [".jpg", ".jpeg", ".png", ".tiff", ".tif"]:
                return jsonify({"error": "Unsupported file type"}), 400
    
            # Read image
            image_bytes = file.read()
            image = Image.open(io.BytesIO(image_bytes))

            # Run YOLO detection
            results = model(image)
            result = results[0]

            # Extract detections
            boxes = result.boxes
            class_ids = boxes.cls.cpu().numpy()
            confidences = boxes.conf.cpu().numpy()
            class_names = [model.names[int(cls_id)] for cls_id in class_ids]

            detections = [
                {"class": class_name, "confidence": float(conf)}
                for class_name, conf in zip(class_names, confidences)
            ]

            # Save processed image
            result_image = result.plot()
            if result_image.shape[2] == 3:
                # Convert BGR to RGB (since OpenCV reads as BGR by default)
                result_image_rgb = cv2.cvtColor(result_image, cv2.COLOR_BGR2RGB)
                result_image_pil = Image.fromarray(result_image_rgb, 'RGB')
            else: 
                result_image_gray = result_image[:, :, 0] 
                if result_image_gray.dtype == np.uint16: 
                    # Normalize the 16-bit image to 8-bit
                    result_image_gray = cv2.normalize(result_image_gray, None, 0, 255, cv2.NORM_MINMAX)
                    result_image_gray = result_image_gray.astype(np.uint8) 
                result_image_pil = Image.fromarray(result_image_gray, 'L')
            output_filename = f"processed_{file.filename}.png"
            output_path = os.path.join(OUTPUT_DIR, output_filename)
            result_image_pil.save(output_path, format="PNG")

            return jsonify({
                "detections": detections,
                "image_url": f"/output/{output_filename}"
            }), 200
        #else:
            # TODO VIDEO

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/output/<path:filename>")
def serve_output_file(filename):
    return send_from_directory(OUTPUT_DIR, filename)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
