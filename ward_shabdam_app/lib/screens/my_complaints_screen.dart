import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/complaint.dart';

class MyComplaintsScreen extends StatefulWidget {
  final String mobile;

  const MyComplaintsScreen({
    super.key,
    required this.mobile,
  });

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {

  List<Complaint> complaints = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadComplaints();
  }

  Future<void> loadComplaints() async {
    try {
      final data = await ApiService.getMyComplaints(widget.mobile);
      if (!mounted) return;
      setState(() {
        complaints = data;
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

  Color statusColor(String status) {
    switch (status) {
      case "Resolved":
        return Colors.green;

      case "In Progress":
        return Colors.orange;

      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Complaints"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

            : errorMessage != null
              ? Center(child: Text(errorMessage!))
            : complaints.isEmpty
              ? const Center(
                  child: Text(
                    "No complaints found.",
                    style: TextStyle(fontSize: 18),
                  ),
                )

              : ListView.builder(
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {

                    final complaint = complaints[index];

                    return Card(
                      margin: const EdgeInsets.all(10),

                      child: Padding(
                        padding: const EdgeInsets.all(15),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text(
                              "Complaint #${complaint.id}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text("Category : ${complaint.category}"),

                            const SizedBox(height: 5),

                            Text("Ward : ${complaint.ward}"),

                            const SizedBox(height: 5),

                            Text(
                              complaint.description,
                            ),

                            const SizedBox(height: 10),

                            Chip(
                              label: Text(
                                complaint.status,
                              ),
                              backgroundColor:
                                  statusColor(complaint.status),
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