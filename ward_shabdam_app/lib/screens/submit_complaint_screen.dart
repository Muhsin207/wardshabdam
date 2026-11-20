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
    const primaryColor = Color(0xFF0D5C3A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('പരാതി നൽകുക / Report Issue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "പരാതി വിവരങ്ങൾ രേഖപ്പെടുത്തുക",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Fill out details to notify your Ward Member directly",
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: Icon(Icons.phone_android_rounded),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Enter your mobile number' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: selectedWard,
                      decoration: const InputDecoration(
                        labelText: 'വാർഡ് തിരഞ്ഞെടുക്കുക / Ward',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: wards.map((ward) => DropdownMenuItem(value: ward, child: Text(ward))).toList(),
                      onChanged: (value) => setState(() => selectedWard = value),
                      validator: (value) => value == null ? 'Select a ward' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'വിഭാഗം / Category',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                      onChanged: (value) => setState(() => selectedCategory = value),
                      validator: (value) => value == null ? 'Select a category' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'പരാതി വിവരണം / Description',
                        hintText: 'Describe location, landmark, and the issue...',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 50),
                          child: Icon(Icons.notes_rounded),
                        ),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Enter a complaint description' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          'പരാതി സമർപ്പിക്കുക / SUBMIT',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}