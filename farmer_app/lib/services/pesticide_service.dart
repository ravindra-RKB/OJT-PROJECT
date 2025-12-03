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
  Future<Map<String, dynamic>?> getPesticideInfo(String diseaseName) async {
    if (!_isLoaded) {
      await loadPesticides();
    }

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
}


