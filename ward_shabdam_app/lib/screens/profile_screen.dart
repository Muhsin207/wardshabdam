import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String fullname;
  final String mobile;
  final String email;

  const ProfileScreen({
    super.key,
    required this.fullname,
    required this.mobile,
    required this.email,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController fullnameController;
  late final TextEditingController emailController;
  bool editing = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    fullnameController = TextEditingController(text: widget.fullname);
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    final fullname = fullnameController.text.trim();
    final email = emailController.text.trim();
    if (fullname.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required')),
      );
      return;
    }

    setState(() => saving = true);
    try {
      final result = await ApiService.updateProfile(
        mobile: widget.mobile,
        fullname: fullname,
        email: email,
      );
      if (!mounted) return;
      setState(() {
        saving = false;
        editing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'Profile updated')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: editing ? 'Cancel editing' : 'Edit profile',
            onPressed: saving ? null : () => setState(() => editing = !editing),
            icon: Icon(editing ? Icons.close : Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 60),
            ),
            const SizedBox(height: 20),
            if (editing) ...[
              TextFormField(
                controller: fullnameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving ? null : saveProfile,
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('SAVE PROFILE'),
                ),
              ),
            ] else ...[
              Text(
                fullnameController.text,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.mobile, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 30),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Mobile Number'),
                  subtitle: Text(widget.mobile),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Full Name'),
                  subtitle: Text(fullnameController.text),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(emailController.text),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangePasswordScreen(mobile: widget.mobile),
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About Wardshabdam'),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
    );
  }
}