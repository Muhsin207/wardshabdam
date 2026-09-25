import 'package:flutter/material.dart';

import '../models/gallery_photo.dart';
import '../services/api_service.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<List<GalleryPhoto>> gallery;

  @override
  void initState() {
    super.initState();
    gallery = ApiService.getGallery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: FutureBuilder<List<GalleryPhoto>>(
        future: gallery,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return const Center(child: Text('Unable to load gallery'));
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No gallery photos available'));
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .82,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final imageUrl = ApiService.resourceUrl(item.photoUrl);
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: imageUrl.isEmpty
                          ? const Center(child: Icon(Icons.photo, size: 48))
                          : Image.network(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image)),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
