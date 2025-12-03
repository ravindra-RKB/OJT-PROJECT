<<<<<<< HEAD
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

=======
/// Service responsible for providing pesticide information for a given disease.
///
/// This is a simple in-memory lookup so the screen can work end‑to‑end.
/// You can later replace this with data from Firestore, REST API, etc.
class PesticideService {
  bool _isLoaded = false;

  // Example data. Adjust to your real crop/disease names.
  final Map<String, Map<String, dynamic>> _pesticideDatabase = {
    'Sample Leaf Disease': {
      'organic': 'Neem oil spray',
      'chemical': 'Mancozeb 75% WP',
      'dosage': '2–3 g per liter of water. Spray in the early morning or late afternoon.',
      'precautions':
          'Wear gloves and a mask. Avoid spraying during strong winds. Keep away from children and animals.',
    },
  };

  Future<void> loadPesticides() async {
    // TODO: Replace with real data loading if needed.
    await Future.delayed(const Duration(milliseconds: 200));
    _isLoaded = true;
  }

  /// Returns a pesticide info map for the provided [diseaseName].
  ///
  /// The returned map may contain keys:
  /// - 'organic'
  /// - 'chemical'
  /// - 'dosage'
  /// - 'precautions'
  ///
  /// Returns null if no information is available.
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
  Future<Map<String, dynamic>?> getPesticideInfo(String diseaseName) async {
    if (!_isLoaded) {
      await loadPesticides();
    }

<<<<<<< HEAD
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
=======
    // Try direct match first.
    if (_pesticideDatabase.containsKey(diseaseName)) {
      return _pesticideDatabase[diseaseName];
    }

    // Fallback generic recommendation.
    return {
      'organic': 'Neem oil or garlic-chili extract spray',
      'chemical': 'Contact your local agri expert for a recommended fungicide.',
      'dosage': 'Follow the manufacturer label on the product you choose.',
      'precautions':
          'Always wear gloves, mask, and protective clothing. Do not spray near water bodies.',
    };
  }
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
}


