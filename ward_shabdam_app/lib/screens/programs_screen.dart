import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/program.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  List<Program> programs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPrograms();
  }

  Future<void> loadPrograms() async {
    try {
      final data = await ApiService.getPrograms();

      if (!mounted) return;
      setState(() {
        programs = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Government Programs"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
            : errorMessage != null
              ? Center(child: Text(errorMessage!))
            : programs.isEmpty
              ? const Center(
                  child: Text("No Programs Available"),
                )
              : ListView.builder(
                  itemCount: programs.length,
                  itemBuilder: (context, index) {
                    final program = programs[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                                if (program.photo.isNotEmpty)
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                    ApiService.imageUrl(program.photo),
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    ),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                program.title,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                ),
                                ),

                                const SizedBox(height: 8),

                                Text(program.description),
                            ],
                        )
                      ),
                    );
                  },
                ),
    );
  }
}