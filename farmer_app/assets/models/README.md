# Plant Disease Detection Model

Place your TensorFlow Lite model file here:

- **File name**: `plant_disease.tflite`
- **Location**: `assets/models/plant_disease.tflite`

## Model Requirements

- Input shape: [1, 224, 224, 3] (RGB image, normalized to [0, 1])
- Output shape: [1, N] where N is the number of disease classes
- Output format: Softmax probabilities for each class

## Model Classes

The model should output predictions for the following classes (in order):
1. Tomato Early Blight
2. Tomato Late Blight
3. Tomato Leaf Mold
4. Tomato Septoria Leaf Spot
5. Tomato Spider Mites
6. Tomato Target Spot
7. Tomato Yellow Leaf Curl Virus
8. Tomato Mosaic Virus
9. Tomato Healthy
10. Potato Early Blight
11. Potato Late Blight
12. Potato Healthy
13. Pepper Bell Bacterial Spot
14. Pepper Bell Healthy
15. Corn Common Rust
16. Corn Gray Leaf Spot
17. Corn Healthy
18. Apple Scab
19. Apple Black Rot
20. Apple Cedar Rust
21. Apple Healthy
22. Cherry Powdery Mildew
23. Cherry Healthy
24. Grape Black Rot
25. Grape Esca
26. Grape Healthy
27. Strawberry Leaf Scorch
28. Strawberry Healthy

**Note**: Update the `_diseaseClasses` list in `disease_detection_service.dart` if your model uses different class names or order.


