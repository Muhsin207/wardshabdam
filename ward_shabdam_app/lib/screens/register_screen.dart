import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullname = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final ward = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool saving = false;

  @override
  void dispose() {
    for (final controller in [fullname, mobile, email, ward, password, confirmPassword]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> register() async {
    if (password.text.length < 8 || password.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords must match and be at least 8 characters')));
      return;
    }
    setState(() => saving = true);
    try {
      final result = await ApiService.register(
        fullname: fullname.text.trim(),
        mobile: mobile.text.trim(),
        email: email.text.trim(),
        ward: ward.text.trim(),
        password: password.text,
        confirmPassword: confirmPassword.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']?.toString() ?? 'Registration successful')));
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
      appBar: AppBar(title: const Text('Register')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final field in [
            (fullname, 'Full name', false),
            (mobile, 'Mobile number', false),
            (email, 'Email', false),
            (ward, 'Ward', false),
            (password, 'Password', true),
            (confirmPassword, 'Confirm password', true),
          ]) ...[
            TextField(controller: field.$1, obscureText: field.$3, decoration: InputDecoration(labelText: field.$2, border: const OutlineInputBorder())),
            const SizedBox(height: 14),
          ],
          ElevatedButton(onPressed: saving ? null : register, child: saving ? const CircularProgressIndicator() : const Text('REGISTER')),
        ],
      ),
    );
  }
}
