import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final mobile = TextEditingController();
  final email = TextEditingController();
  final code = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool codeSent = false;
  bool saving = false;

  @override
  void dispose() {
    for (final controller in [mobile, email, code, password, confirmPassword]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> requestCode() async {
    setState(() => saving = true);
    try {
      final result = await ApiService.requestPasswordReset(mobile: mobile.text.trim(), email: email.text.trim());
      if (!mounted) return;
      setState(() {
        saving = false;
        codeSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']?.toString() ?? 'Reset code sent')));
    } catch (error) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> resetPassword() async {
    if (password.text.length < 8 || password.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords must match and be at least 8 characters')));
      return;
    }
    setState(() => saving = true);
    try {
      final result = await ApiService.resetPassword(
        mobile: mobile.text.trim(),
        code: code.text.trim(),
        password: password.text,
        confirmPassword: confirmPassword.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']?.toString() ?? 'Password reset')));
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
      appBar: AppBar(title: const Text('Reset Password')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: mobile, decoration: const InputDecoration(labelText: 'Mobile number', border: OutlineInputBorder())),
          const SizedBox(height: 14),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          const SizedBox(height: 14),
          if (!codeSent)
            ElevatedButton(onPressed: saving ? null : requestCode, child: saving ? const CircularProgressIndicator() : const Text('SEND RESET CODE'))
          else ...[
            TextField(controller: code, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Email reset code', border: OutlineInputBorder())),
            const SizedBox(height: 14),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'New password', border: OutlineInputBorder())),
            const SizedBox(height: 14),
            TextField(controller: confirmPassword, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm password', border: OutlineInputBorder())),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: saving ? null : resetPassword, child: saving ? const CircularProgressIndicator() : const Text('RESET PASSWORD')),
          ],
        ],
      ),
    );
  }
}
