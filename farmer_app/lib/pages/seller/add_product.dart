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

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  final List<dynamic> _images = [];
  bool _loading = false;
  double? _latitude;
  double? _longitude;
  String? _address;

  final ProductService _service = ProductService();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // allow multi-select on platforms that support it
    try {
      if (!kIsWeb) {
        final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
        if (picked != null) {
          setState(() {
            _images.add(File(picked.path));
          });
        }
      } else {
        // web: pickMultiImage returns List<XFile>
        final List<XFile>? pickedList = await picker.pickMultiImage(imageQuality: 80);
        if (pickedList != null && pickedList.isNotEmpty) {
          setState(() {
            for (final xf in pickedList) _images.add(xf);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image pick error: $e')));
    }
  }

  Future<void> _getLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return;
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
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
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              Row(children: [
                Expanded(child: TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _unitCtrl, decoration: const InputDecoration(labelText: 'Unit'))),
              ]),
              Row(children: [
                Expanded(child: TextFormField(controller: _qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _categoryCtrl, decoration: const InputDecoration(labelText: 'Category'))),
              ]),
              const SizedBox(height: 12),
              ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text('Pick Image')),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, i) {
                    final img = _images[i];
                    if (kIsWeb) {
                      if (img is XFile) {
                        return FutureBuilder<Uint8List>(
                          future: img.readAsBytes(),
                          builder: (context, snap) {
                            if (snap.connectionState != ConnectionState.done) return const SizedBox(width: 100, height: 100, child: Center(child: CircularProgressIndicator()));
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.memory(snap.data!, width: 100, height: 100, fit: BoxFit.cover),
                            );
                          },
                        );
                      }
                      // fallback
                      return const SizedBox.shrink();
                    } else {
                      // mobile/desktop
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.file(img as File, width: 100, height: 100, fit: BoxFit.cover),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(onPressed: _getLocation, icon: const Icon(Icons.my_location), label: const Text('Use Current Location')),
              if (_address != null) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(_address!)),
              const SizedBox(height: 16),
              _loading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submit, child: const Text('Add Product')),
            ],
          ),
        ),
      ),
    );
  }
}
