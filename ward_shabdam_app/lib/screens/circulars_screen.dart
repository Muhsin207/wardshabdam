import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/circular.dart';
import '../services/api_service.dart';

class CircularsScreen extends StatefulWidget {
  const CircularsScreen({super.key});

  @override
  State<CircularsScreen> createState() => _CircularsScreenState();
}

class _CircularsScreenState extends State<CircularsScreen> {
  late Future<List<Circular>> circulars;

  @override
  void initState() {
    super.initState();
    circulars = ApiService.getCirculars();
  }

  Future<void> openCircular(String path) async {
    final uri = Uri.parse(ApiService.resourceUrl(path));
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open circular')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Circulars')),
      body: FutureBuilder<List<Circular>>(
        future: circulars,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return const Center(child: Text('Unable to load circulars'));
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No circulars available'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: Icon(item.important ? Icons.priority_high : Icons.article),
                  title: Text(item.title),
                  subtitle: Text(item.description),
                  trailing: item.fileUrl.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Open circular',
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => openCircular(item.fileUrl),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
