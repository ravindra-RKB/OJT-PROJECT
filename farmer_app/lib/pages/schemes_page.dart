import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/scheme_provider.dart';
import '../models/government_scheme.dart';

class SchemesPage extends StatefulWidget {
  const SchemesPage({super.key});

  @override
  State<SchemesPage> createState() => _SchemesPageState();
}

class _SchemesPageState extends State<SchemesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchemeProvider>().fetchSchemes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE7),
      appBar: AppBar(
        title: const Text('Government Schemes'),
        backgroundColor: const Color(0xFF617A2E),
        foregroundColor: Colors.white,
      ),
      body: Consumer<SchemeProvider>(
        builder: (context, schemeProvider, child) {
          if (schemeProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (schemeProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(schemeProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => schemeProvider.fetchSchemes(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (schemeProvider.schemes.isEmpty) {
            return const Center(
              child: Text('No schemes available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => schemeProvider.fetchSchemes(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: schemeProvider.schemes.length,
              itemBuilder: (context, index) {
                final scheme = schemeProvider.schemes[index];
                return _buildSchemeCard(scheme);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSchemeCard(GovernmentScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF617A2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              scheme.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheme.description,
                  style: const TextStyle(fontSize: 14),
                ),
                if (scheme.eligibility != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Eligibility:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scheme.eligibility!,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
                if (scheme.benefits != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Benefits:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scheme.benefits!,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
                if (scheme.applicationLink != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final uri = Uri.parse(scheme.applicationLink!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF617A2E),
                      ),
                      child: const Text('Apply Now'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

