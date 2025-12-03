// lib/services/pesticide_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';

class PesticideService {
  Map<String, dynamic>? _pesticideData;
  bool _isLoaded = false;

  Future<void> loadPesticides() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/pesticides.json');
      _pesticideData = json.decode(jsonString) as Map<String, dynamic>;
      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load pesticides data: $e');
    }
  }

  Future<Map<String, dynamic>?> getPesticideInfo(String diseaseName) async {
    if (!_isLoaded) {
      await loadPesticides();
    }

    if (_pesticideData == null) {
      return null;
    }

    // Try exact match first
    if (_pesticideData!.containsKey(diseaseName)) {
      return Map<String, dynamic>.from(_pesticideData![diseaseName] as Map);
    }

    // Try partial match (e.g., "Tomato Early Blight" matches "Early Blight")
    for (final key in _pesticideData!.keys) {
      if (diseaseName.toLowerCase().contains(key.toLowerCase()) ||
          key.toLowerCase().contains(diseaseName.toLowerCase())) {
        return Map<String, dynamic>.from(_pesticideData![key] as Map);
      }
    }

    // Try matching by crop type (e.g., "Tomato" in disease name)
    final cropTypes = ['Tomato', 'Potato', 'Pepper', 'Corn', 'Apple', 'Cherry', 'Grape', 'Strawberry'];
    for (final crop in cropTypes) {
      if (diseaseName.contains(crop)) {
        // Look for a generic entry for this crop
        for (final key in _pesticideData!.keys) {
          if (key.contains(crop)) {
            return Map<String, dynamic>.from(_pesticideData![key] as Map);
          }
        }
      }
    }

    // Return default/fallback information if no match found
    return {
      'organic': 'Neem oil',
      'chemical': 'General fungicide',
      'dosage': 'As per manufacturer instructions',
      'precautions': 'Follow safety guidelines and wear protective equipment',
      'organicSearch': 'neem oil pesticide',
      'chemicalSearch': 'plant fungicide',
    };
  }

  Map<String, dynamic>? getAllPesticides() {
    return _pesticideData;
  }
}


