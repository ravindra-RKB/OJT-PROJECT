import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mandi_provider.dart';

class MarketPricesPage extends StatefulWidget {
  const MarketPricesPage({super.key});

  @override
  State<MarketPricesPage> createState() => _MarketPricesPageState();
}

class _MarketPricesPageState extends State<MarketPricesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MandiProvider>().fetchPrices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE7),
      appBar: AppBar(
        title: const Text('Mandi Prices'),
        backgroundColor: const Color(0xFF617A2E),
        foregroundColor: Colors.white,
      ),
      body: Consumer<MandiProvider>(
        builder: (context, mandiProvider, child) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search commodity...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              mandiProvider.fetchPrices();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      mandiProvider.fetchPrices();
                    } else {
                      mandiProvider.searchCommodity(value);
                    }
                  },
                ),
              ),
              // Content
              Expanded(
                child: mandiProvider.loading
                    ? const Center(child: CircularProgressIndicator())
                    : mandiProvider.prices.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.inventory_2_outlined,
                                    size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text('No prices available'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => mandiProvider.fetchPrices(),
                                  child: const Text('Refresh'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => mandiProvider.fetchPrices(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: mandiProvider.prices.length,
                              itemBuilder: (context, index) {
                                final price = mandiProvider.prices[index];
                                return _buildPriceCard(price);
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPriceCard(price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF617A2E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: Color(0xFF617A2E),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price.commodity,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price.market,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (price.district != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${price.district}, ${price.state ?? ""}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${price.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF617A2E),
                ),
              ),
              Text(
                '/ ${price.unit}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMM yyyy').format(price.date),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

