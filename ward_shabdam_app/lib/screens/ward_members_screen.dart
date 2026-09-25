import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class WardMembersScreen extends StatefulWidget {
  const WardMembersScreen({super.key});

  @override
  State<WardMembersScreen> createState() => _WardMembersScreenState();
}

class _WardMembersScreenState extends State<WardMembersScreen> {
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> callMember(String phone) async {
  final Uri uri = Uri(scheme: 'tel', path: phone);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

Future<void> emailMember(String email) async {
  final Uri uri = Uri(
    scheme: 'mailto',
    path: email,
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> loadMembers() async {
    try {
      final data = await ApiService.getWardMembers();
      if (!mounted) return;
      setState(() {
        members = data;
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
        title: const Text("Ward Members"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
              ? Center(child: Text(errorMessage!))
            : members.isEmpty
              ? const Center(child: Text("No ward members found."))
            : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: member["photo"] != null &&
                              member["photo"].toString().isNotEmpty
                          ? NetworkImage(
                              ApiService.imageUrl(member["photo"].toString()),
                            )
                          : null,
                      child: member["photo"] == null ||
                              member["photo"].toString().isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(member["name"]?.toString() ?? "Unknown member"),
                    subtitle: Text(
                      "Ward ${member["ward_no"] ?? "Unknown"}\n${member["designation"] ?? ""}",
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call),
                          onPressed: () {
                            callMember(member["mobile"]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.email),
                          onPressed: () {
                            emailMember(member["email"]);
                          },
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