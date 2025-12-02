import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  final List<dynamic> _images = [];
  // track per-image upload progress
  final List<int> _bytesTransferred = [];
  final List<int?> _bytesTotal = [];
  bool _loading = false;
  double? _latitude;
  double? _longitude;
  String? _address;

  late AnimationController _fadeController;

  final ProductService _service = ProductService();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _unitCtrl.dispose();
    _qtyCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // allow multi-select on platforms that support it
    try {
      if (!kIsWeb) {
        final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
        if (picked != null) {
          setState(() {
            _images.add(File(picked.path));
            _bytesTransferred.add(0);
            _bytesTotal.add(null);
          });
        }
      } else {
        // web: pickMultiImage returns List<XFile>
        final pickedList = await picker.pickMultiImage(imageQuality: 80);
        if (pickedList.isNotEmpty) {
          setState(() {
            for (final xf in pickedList) {
              _images.add(xf);
              _bytesTransferred.add(0);
              _bytesTotal.add(null);
            }
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image pick error: $e')));
    }
  }

  Future<void> _getLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return;
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    if (!mounted) return;
    setState(() {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
      _address = 'Lat: ${pos.latitude.toStringAsFixed(4)}, Lon: ${pos.longitude.toStringAsFixed(4)}';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in as a seller')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _service.createProduct(
        sellerId: user.uid,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text) ?? 0,
        unit: _unitCtrl.text.trim(),
        imageFiles: _images,
        latitude: _latitude ?? 0,
        longitude: _longitude ?? 0,
        address: _address ?? '',
        availableQuantity: int.tryParse(_qtyCtrl.text) ?? 0,
        category: _categoryCtrl.text.trim(),
        onImageProgress: (index, transferred, total) {
          if (!mounted) return;
          setState(() {
            if (index >= _bytesTransferred.length) {
              while (_bytesTransferred.length <= index) {
                _bytesTransferred.add(0);
              }
              while (_bytesTotal.length <= index) {
                _bytesTotal.add(null);
              }
            }
            _bytesTransferred[index] = transferred;
            _bytesTotal[index] = total;
          });
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added')));
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF2D5016), const Color(0xFF617A2E)],
          ),
        ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Add Your Product',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1B3A0B), const Color(0xFF2D5016)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8BC34A).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.agriculture, color: Color(0xFF8BC34A), size: 24),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fresh from Your Farm',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Text(
                                      'Reach customers directly',
                                      style: TextStyle(color: Color(0xFF8BC34A), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Product Name
                        _buildModernTextField(
                          controller: _nameCtrl,
                          label: 'Product Name',
                          hint: 'e.g., Fresh Tomatoes',
                          icon: Icons.local_florist,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        _buildModernTextField(
                          controller: _descCtrl,
                          label: 'Description',
                          hint: 'Describe your product quality and details',
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Price & Unit Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernTextField(
                                controller: _priceCtrl,
                                label: 'Price',
                                hint: '₹0.00',
                                icon: Icons.attach_money,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModernTextField(
                                controller: _unitCtrl,
                                label: 'Unit',
                                hint: 'kg, bunch, etc',
                                icon: Icons.scale,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Quantity & Category Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernTextField(
                                controller: _qtyCtrl,
                                label: 'Available Qty',
                                hint: '0',
                                icon: Icons.inventory_2,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModernTextField(
                                controller: _categoryCtrl,
                                label: 'Category',
                                hint: 'e.g., Vegetables',
                                icon: Icons.category,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Image Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF8BC34A).withOpacity(0.3), width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8BC34A).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.image, color: Color(0xFF8BC34A), size: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Product Images',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: _images.isEmpty ? 80 : 110,
                                child: _images.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.image_not_supported, color: Colors.white.withOpacity(0.5), size: 32),
                                            const SizedBox(height: 8),
                                            Text(
                                              'No images selected',
                                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _images.length,
                                        itemBuilder: (context, i) {
                                          final img = _images[i];
                                          Widget thumb;
                                          if (kIsWeb) {
                                            if (img is XFile) {
                                              thumb = FutureBuilder<Uint8List>(
                                                future: img.readAsBytes(),
                                                builder: (context, snap) {
                                                  if (snap.connectionState != ConnectionState.done) {
                                                    return const SizedBox(width: 100, height: 100, child: Center(child: CircularProgressIndicator()));
                                                  }
                                                  return Image.memory(snap.data!, width: 100, height: 100, fit: BoxFit.cover);
                                                },
                                              );
                                            } else {
                                              thumb = const SizedBox.shrink();
                                            }
                                          } else {
                                            thumb = Image.file(img as File, width: 100, height: 100, fit: BoxFit.cover);
                                          }

                                          final transferred = i < _bytesTransferred.length ? _bytesTransferred[i] : 0;
                                          final total = i < _bytesTotal.length ? _bytesTotal[i] : null;

                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Stack(
                                              alignment: Alignment.bottomCenter,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: const Color(0xFF8BC34A).withOpacity(0.4), width: 1),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(0xFF8BC34A).withOpacity(0.2),
                                                        blurRadius: 8,
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: SizedBox(width: 100, height: 100, child: thumb),
                                                  ),
                                                ),
                                                if (_loading)
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: ClipRRect(
                                                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                                                      child: total != null && total > 0
                                                          ? LinearProgressIndicator(value: transferred / total, minHeight: 4, backgroundColor: Colors.transparent, valueColor: const AlwaysStoppedAnimation(Color(0xFF8BC34A)))
                                                          : const LinearProgressIndicator(minHeight: 4, backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation(Color(0xFF8BC34A))),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8BC34A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.add_photo_alternate),
                                  label: const Text('Pick Images', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Location Section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8BC34A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF8BC34A).withOpacity(0.3), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Color(0xFF8BC34A), size: 20),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Location',
                                      style: TextStyle(
                                        color: Color(0xFF8BC34A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  if (_latitude != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8BC34A).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Set',
                                        style: TextStyle(color: Color(0xFF8BC34A), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                              if (_address != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _address!,
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                  maxLines: 2,
                                ),
                              ],
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _getLocation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8BC34A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.my_location, size: 18),
                                  label: const Text('Use Current Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        if (!_loading)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [const Color(0xFF8BC34A), const Color(0xFF617A2E)]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8BC34A).withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'Add Product',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Color(0xFF8BC34A)),
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF8BC34A), fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        prefixIcon: Icon(icon, color: const Color(0xFF8BC34A), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFF8BC34A).withOpacity(0.3), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: const Color(0xFF8BC34A).withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF8BC34A), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
