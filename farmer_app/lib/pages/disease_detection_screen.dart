<<<<<<< HEAD
// lib/pages/disease_detection_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
=======
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
import '../services/disease_detection_service.dart';
import '../services/pesticide_service.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isModelLoading = false;
  String? _diseaseName;
  double? _confidence;
  Map<String, dynamic>? _pesticideInfo;

  final DiseaseDetectionService _diseaseService = DiseaseDetectionService();
  final PesticideService _pesticideService = PesticideService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() {
      _isModelLoading = true;
    });
    try {
      await _diseaseService.loadModel();
      await _pesticideService.loadPesticides();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing services: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isModelLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _diseaseName = null;
          _confidence = null;
          _pesticideInfo = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _detectDisease() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _diseaseName = null;
      _confidence = null;
      _pesticideInfo = null;
    });

    try {
      final result = await _diseaseService.detectDisease(_selectedImage!);
<<<<<<< HEAD
      
      if (result != null) {
        final diseaseName = result['disease'];
        final confidence = result['confidence'];
        
        final pesticideInfo = await _pesticideService.getPesticideInfo(diseaseName);
        
=======

      if (result != null) {
        final diseaseName = result['disease'];
        final confidence = result['confidence'];

        final pesticideInfo =
            await _pesticideService.getPesticideInfo(diseaseName);

>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
        setState(() {
          _diseaseName = diseaseName;
          _confidence = confidence;
          _pesticideInfo = pesticideInfo;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
            const SnackBar(content: Text('Could not detect disease. Please try another image.')),
=======
            const SnackBar(
                content: Text(
                    'Could not detect disease. Please try another image.')),
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error detecting disease: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detection'),
        backgroundColor: const Color(0xFF617A2E),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
<<<<<<< HEAD
              const Color(0xFF617A2E).withValues(alpha: 0.1),
=======
              const Color(0xFF617A2E).withOpacity(0.1),
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
              const Color(0xFFF3EFE7),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Section
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
<<<<<<< HEAD
                      color: Colors.grey.withValues(alpha: 0.2),
=======
                      color: Colors.grey.withOpacity(0.2),
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No image selected',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Pick Image Button
              ElevatedButton.icon(
                onPressed: _isModelLoading ? null : _showImageSourceDialog,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Pick Image from Camera/Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF617A2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Detect Disease Button
              ElevatedButton.icon(
<<<<<<< HEAD
                onPressed: (_isLoading || _isModelLoading || _selectedImage == null)
                    ? null
                    : _detectDisease,
=======
                onPressed:
                    (_isLoading || _isModelLoading || _selectedImage == null)
                        ? null
                        : _detectDisease,
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
<<<<<<< HEAD
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
=======
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(_isLoading ? 'Detecting...' : 'Detect Disease'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BC34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Results Card
              if (_diseaseName != null && _pesticideInfo != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
<<<<<<< HEAD
                        color: Colors.grey.withValues(alpha: 0.2),
=======
                        color: Colors.grey.withOpacity(0.2),
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Disease Name
                      Row(
                        children: [
                          Icon(
                            Icons.bug_report,
                            color: Colors.red[700],
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _diseaseName!,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF617A2E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Confidence
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.analytics, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Pesticide Recommendations
                      const Text(
                        'Recommended Pesticides',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Organic Pesticide
                      if (_pesticideInfo!['organic'] != null)
                        _buildPesticideCard(
                          'Organic',
                          _pesticideInfo!['organic'],
                          Colors.green,
                          Icons.eco,
<<<<<<< HEAD
                          searchTerm: _pesticideInfo!['organicSearch'] ?? _pesticideInfo!['organic'],
=======
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
                        ),
                      const SizedBox(height: 12),

                      // Chemical Pesticide
                      if (_pesticideInfo!['chemical'] != null)
                        _buildPesticideCard(
                          'Chemical',
                          _pesticideInfo!['chemical'],
                          Colors.orange,
                          Icons.science,
<<<<<<< HEAD
                          searchTerm: _pesticideInfo!['chemicalSearch'] ?? _pesticideInfo!['chemical'],
=======
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
                        ),
                      const SizedBox(height: 20),

                      // Dosage
                      if (_pesticideInfo!['dosage'] != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber[300]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
<<<<<<< HEAD
                              Icon(Icons.medication_liquid, color: Colors.amber[800]),
=======
                              Icon(Icons.medication_liquid,
                                  color: Colors.amber[800]),
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Dosage',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _pesticideInfo!['dosage'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Precautions
                      if (_pesticideInfo!['precautions'] != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
<<<<<<< HEAD
                              Icon(Icons.warning_amber_rounded, color: Colors.red[800]),
=======
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.red[800]),
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Precautions',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _pesticideInfo!['precautions'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

              // Loading indicator for model
              if (_isModelLoading)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPesticideCard(
    String type,
    String name,
    MaterialColor color,
<<<<<<< HEAD
    IconData icon, {
    required String searchTerm,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 12,
                        color: color.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Buy buttons row
          Row(
            children: [
              Expanded(
                child: _buildBuyButton(
                  label: 'Buy on Flipkart',
                  icon: Icons.shopping_cart,
                  color: const Color(0xFF2874F0),
                  onTap: () => _openFlipkart(searchTerm),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBuyButton(
                  label: 'Buy on Amazon',
                  icon: Icons.shopping_bag,
                  color: const Color(0xFFFF9900),
                  onTap: () => _openAmazon(searchTerm),
                ),
              ),
            ],
=======
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildBuyButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFlipkart(String searchTerm) async {
    final encodedQuery = Uri.encodeComponent(searchTerm);
    final url = Uri.parse('https://www.flipkart.com/search?q=$encodedQuery');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Flipkart')),
        );
      }
    }
  }

  Future<void> _openAmazon(String searchTerm) async {
    final encodedQuery = Uri.encodeComponent(searchTerm);
    final url = Uri.parse('https://www.amazon.in/s?k=$encodedQuery');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Amazon')),
        );
      }
    }
  }
}

=======
}


>>>>>>> cd7762c3a1b097ed2e49c44afa1e1949ebaa2a28
