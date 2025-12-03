<<<<<<< HEAD
// lib/services/disease_detection_service.dart
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class DiseaseDetectionService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // List of disease classes (update this based on your model's output classes)
  // This is a placeholder - you should replace with your actual model's class names
  final List<String> _diseaseClasses = [
    'Tomato Early Blight',
    'Tomato Late Blight',
    'Tomato Leaf Mold',
    'Tomato Septoria Leaf Spot',
    'Tomato Spider Mites',
    'Tomato Target Spot',
    'Tomato Yellow Leaf Curl Virus',
    'Tomato Mosaic Virus',
    'Tomato Healthy',
    'Potato Early Blight',
    'Potato Late Blight',
    'Potato Healthy',
    'Pepper Bell Bacterial Spot',
    'Pepper Bell Healthy',
    'Corn Common Rust',
    'Corn Gray Leaf Spot',
    'Corn Healthy',
    'Apple Scab',
    'Apple Black Rot',
    'Apple Cedar Rust',
    'Apple Healthy',
    'Cherry Powdery Mildew',
    'Cherry Healthy',
    'Grape Black Rot',
    'Grape Esca',
    'Grape Healthy',
    'Strawberry Leaf Scorch',
    'Strawberry Healthy',
  ];

  Future<void> loadModel() async {
    if (_isModelLoaded) return;

    try {
      // Load the model from assets
      const modelPath = 'assets/models/plant_disease.tflite';

      final modelData = await rootBundle.load(modelPath);
      if (modelData.lengthInBytes == 0) {
        throw Exception(
          'Model file at $modelPath is empty. Please add the actual TFLite model.',
        );
      }

      // Create interpreter options
      final options = InterpreterOptions();

      // Load the model from buffer for better error reporting across platforms
      _interpreter = await Interpreter.fromBuffer(
        modelData.buffer.asUint8List(),
        options: options,
      );

      _isModelLoaded = true;
    } catch (e) {
      throw Exception('Failed to load model: $e');
    }
  }

  Future<Map<String, dynamic>?> detectDisease(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      await loadModel();
    }

    try {
      // Preprocess the image
      final inputImage = await _preprocessImage(imageFile);
      
      // Get model input and output shapes
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      // Prepare input and output buffers
      final inputBuffer = List.generate(
        inputShape[0],
        (_) => List.generate(
          inputShape[1],
          (_) => List.generate(
            inputShape[2],
            (_) => List<double>.filled(inputShape[3], 0.0),
          ),
        ),
      );

      final outputBuffer = List.generate(
        outputShape[0],
        (_) => List<double>.filled(
          outputShape.length > 1 ? outputShape[1] : 1,
          0.0,
        ),
      );
      // Copy preprocessed image to input buffer
      for (int i = 0; i < inputShape[1]; i++) {
        for (int j = 0; j < inputShape[2]; j++) {
          for (int k = 0; k < inputShape[3]; k++) {
            inputBuffer[0][i][j][k] = inputImage[i][j][k];
          }
        }
      }

      // Run inference
      _interpreter!.run(inputBuffer, outputBuffer);

      // Get predictions
      final predictions = outputBuffer[0] as List<double>;
      
      // Find the top prediction
      double maxConfidence = 0.0;
      int maxIndex = 0;
      
      for (int i = 0; i < predictions.length; i++) {
        if (predictions[i] > maxConfidence) {
          maxConfidence = predictions[i];
          maxIndex = i;
        }
      }

      // Get disease name
      String diseaseName = 'Unknown Disease';
      if (maxIndex < _diseaseClasses.length) {
        diseaseName = _diseaseClasses[maxIndex];
      }

      // Skip "Healthy" predictions if confidence is low
      if (diseaseName.contains('Healthy') && maxConfidence < 0.5) {
        // Find the next best non-healthy prediction
        final sortedIndices = List.generate(
          predictions.length,
          (index) => index,
        )..sort((a, b) => predictions[b].compareTo(predictions[a]));

        for (final index in sortedIndices) {
          if (!_diseaseClasses[index].contains('Healthy') && 
              predictions[index] > 0.1) {
            diseaseName = _diseaseClasses[index];
            maxConfidence = predictions[index];
            break;
          }
        }
      }

      return {
        'disease': diseaseName,
        'confidence': maxConfidence,
      };
    } catch (e) {
      throw Exception('Error during disease detection: $e');
    }
  }

  Future<List<List<List<double>>>> _preprocessImage(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();
      
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize to 224x224 (standard input size for many models)
      final resizedImage = img.copyResize(
        image,
        width: 224,
        height: 224,
      );

      // Normalize pixel values to [0, 1] range
      final normalizedImage = List.generate(
        224,
        (i) => List.generate(
          224,
          (j) => List.generate(
            3,
            (k) {
              final pixel = resizedImage.getPixel(j, i);
              double value = 0.0;
              if (k == 0) {
                value = pixel.r / 255.0;
              } else if (k == 1) {
                value = pixel.g / 255.0;
              } else if (k == 2) {
                value = pixel.b / 255.0;
              }
              return value;
            },
          ),
        ),
      );

      return normalizedImage;
    } catch (e) {
      throw Exception('Error preprocessing image: $e');
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
  }
}

=======
import 'dart:io';

/// Service responsible for loading the ML model and running disease detection.
///
/// NOTE: This is a placeholder implementation so the app compiles.
/// Replace the TODO sections with your actual model loading and prediction code
/// (for example using tflite_flutter or another ML package).
class DiseaseDetectionService {
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    // TODO: Load your ML model here.
    // For now we just simulate a small delay.
    await Future.delayed(const Duration(milliseconds: 300));
    _isModelLoaded = true;
  }

  /// Runs disease detection on the given [image].
  ///
  /// Should return a map like:
  /// {
  ///   'disease': 'Leaf Blight',
  ///   'confidence': 0.92,
  /// }
  ///
  /// Currently returns a dummy result so the UI can be tested.
  Future<Map<String, dynamic>?> detectDisease(File image) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    // TODO: Replace this dummy result with real model inference.
    await Future.delayed(const Duration(seconds: 1));

    return {
      'disease': 'Sample Leaf Disease',
      'confidence': 0.87,
    };
  }
}


>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
