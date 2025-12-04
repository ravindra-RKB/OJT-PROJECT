import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';

class AddProductPage extends StatefulWidget {
  final Product? product;
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> with TickerProviderStateMixin {
  bool get _isEditing => widget.product != null;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  final List<dynamic> _images = [];
  List<String> _existingImages = [];
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
    if (_isEditing) {
      final product = widget.product!;
      _nameCtrl.text = product.name;
      _descCtrl.text = product.description;
      _priceCtrl.text = product.price.toStringAsFixed(2);
      _unitCtrl.text = product.unit;
      _qtyCtrl.text = product.availableQuantity.toString();
      _categoryCtrl.text = product.category;
      _latitude = product.latitude;
      _longitude = product.longitude;
      _address = product.address;
      _existingImages = List<String>.from(product.images);
    }
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
      final productName = _nameCtrl.text.trim();
      final price = double.tryParse(_priceCtrl.text) ?? 0;
      final qty = int.tryParse(_qtyCtrl.text) ?? 0;
      Product? resultProduct;

      if (_isEditing) {
        final updated = await _service.updateProduct(
          productId: widget.product!.id,
          name: productName,
          description: _descCtrl.text.trim(),
          price: price,
          unit: _unitCtrl.text.trim(),
          availableQuantity: qty,
          category: _categoryCtrl.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          address: _address,
          replaceImages: _images.isNotEmpty,
          newImageFiles: _images.isNotEmpty ? _images : null,
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
        resultProduct = updated;
        _existingImages = List<String>.from(updated.images);
      } else {
        resultProduct = await _service.createProduct(
          sellerId: user.id,
          name: productName,
          description: _descCtrl.text.trim(),
          price: price,
          unit: _unitCtrl.text.trim(),
          imageFiles: _images,
          latitude: _latitude ?? 0,
          longitude: _longitude ?? 0,
          address: _address ?? '',
          availableQuantity: qty,
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
      }

      if (!mounted) return;
      _showSuccessDialog(resultProduct, isEdit: _isEditing);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 5),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccessDialog(Product product, {required bool isEdit}) {
    bool _autoRedirectScheduled = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // schedule auto-redirect once for non-edit adds
        if (!isEdit && !_autoRedirectScheduled) {
          _autoRedirectScheduled = true;
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            try {
              Navigator.of(ctx).pop();
            } catch (_) {}
            Navigator.of(context).pushNamedAndRemoveUntil('/marketplace', (route) => route.isFirst);
          });
        }

        return AlertDialog(
          title: Text(
            isEdit ? 'Product Updated' : '✓ Product added successfully!',
            style: const TextStyle(color: Color(0xFF617A2E), fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isEdit ? Icons.edit_note : Icons.check_circle, color: const Color(0xFF8BC34A), size: 60),
              const SizedBox(height: 16),
              Text(
                isEdit
                    ? 'Product details have been updated successfully.'
                    : 'Your product "${product.name}" has been added to the marketplace!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF617A2E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag, color: Color(0xFF617A2E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF617A2E)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                    message: 'Edit this product',
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddProductPage(product: product)));
                      },
                      icon: const Icon(Icons.edit, color: Color(0xFF617A2E)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: 'Remove product',
                    child: IconButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        try {
                          await _service.deleteProduct(product.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Product removed.')));
                            Navigator.of(context).maybePop();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('Failed to remove: $e')));
                          }
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8BC34A)),
              onPressed: () {
                Navigator.of(ctx).pop();
                if (!isEdit) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/marketplace', (route) => route.isFirst);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(isEdit ? 'Close' : 'Go to Marketplace',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = _isEditing ? 'Edit Product' : 'Add Your Product';
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
                expandedHeight: 80,
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    pageTitle,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1B3A0B), const Color(0xFF2D5016)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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

                        // Pricing & Inventory (Flipkart style grid)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8BC34A).withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.sell, color: Color(0xFF8BC34A), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Pricing & Inventory',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final bool isWide = constraints.maxWidth > 520;
                                  final double fieldWidth = isWide
                                      ? (constraints.maxWidth - 16) / 2
                                      : constraints.maxWidth;
                                  return Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      SizedBox(
                                        width: fieldWidth,
                                        child: _buildFlipkartFieldCard(
                                          controller: _priceCtrl,
                                          title: 'Price (INR)',
                                          hint: 'Enter selling price',
                                          icon: Icons.currency_rupee,
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                        ),
                                      ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: _buildFlipkartFieldCard(
                                          controller: _unitCtrl,
                                          title: 'Unit',
                                          hint: 'kg | piece | bundle',
                                          icon: Icons.monitor_weight,
                                        ),
                                      ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: _buildFlipkartFieldCard(
                                          controller: _qtyCtrl,
                                          title: 'Available Quantity',
                                          hint: 'Total stock',
                                          icon: Icons.inventory_2_outlined,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      SizedBox(
                                        width: fieldWidth,
                                        child: _buildFlipkartFieldCard(
                                          controller: _categoryCtrl,
                                          title: 'Category',
                                          hint: 'Vegetables | Dairy | Cereals',
                                          icon: Icons.category_outlined,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
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
                              if (_isEditing)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    _images.isEmpty
                                        ? 'Currently using existing gallery. Pick new images to replace.'
                                        : 'New images will replace the existing gallery.',
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                                  ),
                                ),
                              SizedBox(
                                height: (_images.isEmpty ? (_existingImages.isNotEmpty ? 110 : 80) : 110),
                                child: _images.isEmpty
                                    ? (_existingImages.isNotEmpty
                                        ? ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _existingImages.length,
                                            itemBuilder: (context, i) {
                                              final imageUrl = _existingImages[i];
                                              return Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(
                                                            color: const Color(0xFF8BC34A).withOpacity(0.4), width: 1),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Image.network(
                                                          imageUrl,
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 4,
                                                      right: 4,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(0.6),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: const Text(
                                                          'Existing',
                                                          style: TextStyle(color: Colors.white, fontSize: 9),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                        : Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.image_not_supported,
                                                    color: Colors.white.withOpacity(0.5), size: 32),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'No images selected',
                                                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ))
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
                              child: Text(
                                _isEditing ? 'Update Product' : 'Add Product',
                                style: const TextStyle(
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

  Widget _buildFlipkartFieldCard({
    required TextEditingController controller,
    required String title,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
                  color: const Color(0xFF8BC34A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF8BC34A), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8BC34A), width: 2),
              ),
            ),
          ),
        ],
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
