import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/download_document.dart';
import '../services/api_service.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  late Future<List<DownloadDocument>> downloads;

  @override
  void initState() {
    super.initState();
    downloads = ApiService.getDownloads();
  }

  Future<void> openDocument(String path) async {
    final uri = Uri.parse(ApiService.resourceUrl(path));
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open document')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: FutureBuilder<List<DownloadDocument>>(
        future: downloads,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load downloads'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No documents available'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text(item.title),
                  subtitle: Text(item.category.isEmpty ? item.description : item.category),
                  trailing: IconButton(
                    tooltip: 'Open document',
                    icon: const Icon(Icons.open_in_new),
                    onPressed: item.fileUrl.isEmpty ? null : () => openDocument(item.fileUrl),
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
