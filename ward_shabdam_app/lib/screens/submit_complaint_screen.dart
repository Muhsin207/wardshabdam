import 'package:flutter/material.dart';

import '../services/api_service.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final descriptionController = TextEditingController();

  String? selectedWard;
  String? selectedCategory;
  bool isLoading = false;

  final wards = List<String>.generate(17, (index) => 'Ward ${index + 1}');
  final categories = const ['Road', 'Water', 'Electricity', 'Waste', 'Street Light', 'Others'];

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final result = await ApiService.submitComplaint(
        name: nameController.text.trim(),
        mobile: mobileController.text.trim(),
        ward: selectedWard!,
        category: selectedCategory!,
        description: descriptionController.text.trim(),
      );
      if (!mounted) return;
      setState(() => isLoading = false);
      final message = result['message']?.toString() ?? 'Submission failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      if (result['success'] == true) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Complaint')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter your mobile number' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: selectedWard,
                decoration: const InputDecoration(labelText: 'Ward'),
                items: wards.map((ward) => DropdownMenuItem(value: ward, child: Text(ward))).toList(),
                onChanged: (value) => setState(() => selectedWard = value),
                validator: (value) => value == null ? 'Select a ward' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                validator: (value) => value == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Complaint Description'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a complaint description' : null,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  child: isLoading ? const CircularProgressIndicator() : const Text('Submit Complaint'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}