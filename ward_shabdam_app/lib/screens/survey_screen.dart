import 'package:flutter/material.dart';

import '../models/survey.dart';
import '../services/api_service.dart';

class SurveyScreen extends StatefulWidget {
  final String mobile;

  const SurveyScreen({super.key, required this.mobile});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  late Future<Survey?> survey;
  int? selectedOption;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    survey = ApiService.getSurvey();
  }

  Future<void> submitVote() async {
    if (selectedOption == null) return;
    setState(() => submitting = true);
    try {
      final result = await ApiService.voteSurvey(
        mobile: widget.mobile,
        optionId: selectedOption!,
      );
      if (!mounted) return;
      setState(() => submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'Vote submitted')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Survey')),
      body: FutureBuilder<Survey?>(
        future: survey,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return const Center(child: Text('Unable to load survey'));
          final item = snapshot.data;
          if (item == null) return const Center(child: Text('No survey available'));
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(item.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              RadioGroup<int>(
                groupValue: selectedOption,
                onChanged: (value) {
                  if (!submitting && value != null) {
                    setState(() => selectedOption = value);
                  }
                },
                child: Column(
                  children: item.options
                      .map(
                        (option) => RadioListTile<int>(
                          value: option.id,
                          title: Text(option.text),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: submitting || selectedOption == null ? null : submitVote,
                child: submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('SUBMIT VOTE'),
              ),
            ],
          );
        },
      ),
    );
  }
}
