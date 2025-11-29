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

class _ProductListPageState extends State<ProductListPage> with TickerProviderStateMixin {
  final ProductService _service = ProductService();
  List<Product> _products = [];
  bool _loading = true;
  bool _isGrid = false;
  double? _userLat;
  double? _userLng;
  bool _locationFiltered = false;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _load();
    _fabController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFF5F5F5), const Color(0xFFFFFFFF)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: const Color(0xFF617A2E),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('FarmHub Marketplace', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF2D5016), const Color(0xFF617A2E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fresh from Farms', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('Quality products near you', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
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
                      setState(() {
                        _userLat = pos.latitude;
                        _userLng = pos.longitude;
                        _locationFiltered = true;
                      });
                      _load(userLat: _userLat, userLng: _userLng, maxDistanceKm: 30);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location error: $e')));
                    }
                  },
                  icon: const Icon(Icons.my_location, color: Colors.white),
                ),
                IconButton(onPressed: () => Navigator.of(context).pushNamed('/cart'), icon: const Icon(Icons.shopping_cart, color: Colors.white)),
                IconButton(
                  onPressed: () => setState(() => _isGrid = !_isGrid),
                  icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view, color: Colors.white),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _locationFiltered
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8BC34A).withOpacity(0.1),
                          border: Border.all(color: const Color(0xFF8BC34A), width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF617A2E), size: 18),
                            const SizedBox(width: 8),
                            const Expanded(child: Text('Showing products within 30 km', style: TextStyle(color: Color(0xFF617A2E), fontSize: 12))),
                            GestureDetector(
                              onTap: () => setState(() {
                                _locationFiltered = false;
                                _load();
                              }),
                              child: const Text('Clear', style: TextStyle(color: Color(0xFF617A2E), fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            _loading
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF617A2E))),
                          const SizedBox(height: 16),
                          const Text('Loading products...', style: TextStyle(color: Color(0xFF617A2E))),
                        ],
                      ),
                    ),
                  )
                : _products.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_bag_outlined, size: 64, color: Color(0xFFCCCCCC)),
                              const SizedBox(height: 16),
                              const Text('No products found', style: TextStyle(color: Color(0xFF999999), fontSize: 16)),
                              const SizedBox(height: 8),
                              Text('Try adjusting your filters', style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                    : _isGrid
                        ? SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, i) {
                                  final p = _products[i];
                                  return ProductCard(
                                    product: p,
                                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: p))),
                                  );
                                },
                                childCount: _products.length,
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, i) {
                                  final p = _products[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: ProductCard(
                                      product: p,
                                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: p))),
                                    ),
                                  );
                                },
                                childCount: _products.length,
                              ),
                            ),
                          ),
          ],
        ),
      ),
      floatingActionButton: Consumer<AuthProvider>(builder: (context, auth, _) {
        if (auth.user == null) return const SizedBox.shrink();
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(_fabController),
          child: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).pushNamed('/seller/add-product'),
            backgroundColor: const Color(0xFF8BC34A),
            label: const Text('Sell Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        );
      }),
    );
  }
}
