import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
            children: [
              const Icon(
                Icons.account_circle,
                size: 100,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                "Wardshabdam",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Citizen Login",
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 30),

                TextFormField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: "Mobile Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Enter your mobile number"
                      : null,
              ),

              const SizedBox(height: 20),

                TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Enter your password"
                      : null,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => isLoading = true);
                    try {
                      final result = await ApiService.login(
                        mobileController.text.trim(),
                        passwordController.text.trim(),
                      );
                      if (!context.mounted) return;
                      setState(() => isLoading = false);
                      if (result["success"] == true) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            fullname: result["fullname"]?.toString() ?? "Citizen",
                            mobile: mobileController.text.trim(),
                            email: result["email"]?.toString() ?? "",
                          ),
                        ),
                      );
                      } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result["message"]?.toString() ?? "Login failed"),
                        ),
                      );
                      }
                    } catch (error) {
                      if (!context.mounted) return;
                      setState(() => isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      );
                    }
                  },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                ),
                child: const Text('Forgot password?'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('CREATE ACCOUNT'),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}