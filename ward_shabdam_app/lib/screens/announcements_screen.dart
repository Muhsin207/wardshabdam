import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/announcement.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState
    extends State<AnnouncementsScreen> {

  List<Announcement> announcements = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAnnouncements();
  }

  Future<void> loadAnnouncements() async {

    try {
      final data = await ApiService.getAnnouncements();
      if (!mounted) return;
      setState(() {
        announcements = data;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to load announcements")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : announcements.isEmpty
              ? const Center(
                  child: Text(
                    "No Announcements",
                    style: TextStyle(fontSize: 18),
                  ),
                )

              : ListView.builder(
                  itemCount: announcements.length,

                  itemBuilder: (context, index) {

                    final item = announcements[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 4,

                      child: Padding(
                        padding: const EdgeInsets.all(15),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(item.description),

                            const SizedBox(height: 10),

                            Text(
                              item.createdAt,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}