import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/product_service.dart';
import '../../models/product.dart';
import 'product_detail.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _service = ProductService();
  List<Product> _products = [];
  bool _loading = true;
  bool _isGrid = false;
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({double? userLat, double? userLng, double? maxDistanceKm}) async {
    setState(() => _loading = true);
    try {
      final prods = await _service.fetchProducts(userLat: userLat, userLng: userLng, maxDistanceKm: maxDistanceKm);
      setState(() => _products = prods);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace'), actions: [
        IconButton(
            onPressed: () async {
              try {
                bool enabled = await Geolocator.isLocationServiceEnabled();
                if (!enabled) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enable location services')));
                  return;
                }
                LocationPermission permission = await Geolocator.checkPermission();
                if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
                  return;
                }
                final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
                _userLat = pos.latitude;
                _userLng = pos.longitude;
                // reload with 30 km filter
                setState(() => _loading = true);
                final prods = await _service.fetchProducts(userLat: _userLat, userLng: _userLng, maxDistanceKm: 30);
                setState(() {
                  _products = prods;
                  _loading = false;
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location error: $e')));
              }
            },
            icon: const Icon(Icons.location_on)),
          IconButton(onPressed: () => Navigator.of(context).pushNamed('/cart'), icon: const Icon(Icons.shopping_cart)),
            IconButton(
                onPressed: () => setState(() => _isGrid = !_isGrid),
                icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view)),
      ]),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => _load(userLat: _userLat, userLng: _userLng, maxDistanceKm: _userLat != null ? 30 : null),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _isGrid
                        ? GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.78, crossAxisSpacing: 12, mainAxisSpacing: 12),
                            itemCount: _products.length,
                            itemBuilder: (context, i) {
                              final p = _products[i];
                              return ProductCard(
                                product: p,
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: p))),
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: _products.length,
                            itemBuilder: (context, i) {
                              final p = _products[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: ProductCard(product: p, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)))),
                              );
                            },
                          ),
                  ),
                ),
      floatingActionButton: Consumer<AuthProvider>(builder: (context, auth, _) {
        if (auth.user == null) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).pushNamed('/seller/add-product'),
          label: const Text('Sell'),
          icon: const Icon(Icons.add_shopping_cart),
        );
      }),
    );
  }
}
