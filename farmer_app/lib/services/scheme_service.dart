import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/government_scheme.dart';

class SchemeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'government_schemes';

  Future<List<GovernmentScheme>> getSchemes() async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs
          .map((doc) => GovernmentScheme.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      // Return mock data if Firestore fails
      return _getMockSchemes();
    }
  }

  Future<void> addScheme(GovernmentScheme scheme) async {
    await _firestore.collection(collectionName).doc(scheme.id).set(scheme.toJson());
  }

  List<GovernmentScheme> _getMockSchemes() {
    return [
      GovernmentScheme(
        id: '1',
        title: 'Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)',
        description:
            'Direct income support scheme providing ₹6,000 per year to all landholding farmer families.',
        eligibility: 'All landholding farmer families',
        benefits: '₹6,000 per year in three equal installments',
        applicationLink: 'https://pmkisan.gov.in',
        category: 'Income Support',
      ),
      GovernmentScheme(
        id: '2',
        title: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
        description:
            'Crop insurance scheme to provide financial support to farmers in case of crop loss.',
        eligibility: 'All farmers growing notified crops',
        benefits: 'Premium subsidy and comprehensive risk coverage',
        applicationLink: 'https://pmfby.gov.in',
        category: 'Insurance',
      ),
      GovernmentScheme(
        id: '3',
        title: 'Kisan Credit Card (KCC)',
        description:
            'Credit facility for farmers to meet their short-term credit requirements.',
        eligibility: 'All farmers including tenant farmers and sharecroppers',
        benefits: 'Credit up to ₹3 lakh at subsidized interest rate',
        applicationLink: 'https://www.india.gov.in/kisan-credit-card-kcc',
        category: 'Credit',
      ),
      GovernmentScheme(
        id: '4',
        title: 'Soil Health Card Scheme',
        description:
            'Scheme to provide soil health cards to farmers to optimize use of fertilizers.',
        eligibility: 'All farmers',
        benefits: 'Free soil health cards every 3 years',
        applicationLink: 'https://soilhealth.dac.gov.in',
        category: 'Agricultural Support',
      ),
    ];
  }
}

