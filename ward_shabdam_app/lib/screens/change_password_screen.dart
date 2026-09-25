import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String mobile;

  const ChangePasswordScreen({super.key, required this.mobile});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  bool saving = false;

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (newController.text.length < 8 || newController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use an 8-character password and confirm it')),
      );
      return;
    }
    setState(() => saving = true);
    try {
      final result = await ApiService.changePassword(
        mobile: widget.mobile,
        currentPassword: currentController.text,
        newPassword: newController.text,
        confirmPassword: confirmController.text,
      );
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'Password changed')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: currentController, obscureText: true, decoration: const InputDecoration(labelText: 'Current password', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: newController, obscureText: true, decoration: const InputDecoration(labelText: 'New password', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: confirmController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm new password', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saving ? null : save,
            child: saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('CHANGE PASSWORD'),
          ),
        ],
      ),
    );
  }
}
