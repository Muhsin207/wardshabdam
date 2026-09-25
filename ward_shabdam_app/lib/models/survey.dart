class SurveyOption {
  final int id;
  final String text;
  final int votes;

  const SurveyOption({required this.id, required this.text, required this.votes});

  factory SurveyOption.fromJson(Map<String, dynamic> json) {
    return SurveyOption(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      text: json['option_text']?.toString() ?? '',
      votes: json['votes'] is int ? json['votes'] as int : int.tryParse('${json['votes']}') ?? 0,
    );
  }
}

class Survey {
  final int id;
  final String question;
  final List<SurveyOption> options;

  const Survey({required this.id, required this.question, required this.options});

  factory Survey.fromJson(Map<String, dynamic> json, List<Map<String, dynamic>> optionData) {
    return Survey(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      question: json['question']?.toString() ?? '',
      options: optionData.map(SurveyOption.fromJson).toList(),
    );
  }
}
