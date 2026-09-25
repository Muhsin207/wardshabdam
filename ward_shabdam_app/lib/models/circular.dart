class Circular {
  final int id;
  final String title;
  final String description;
  final bool important;
  final String createdAt;
  final String fileUrl;

  const Circular({
    required this.id,
    required this.title,
    required this.description,
    required this.important,
    required this.createdAt,
    required this.fileUrl,
  });

  factory Circular.fromJson(Map<String, dynamic> json) {
    return Circular(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? 'Untitled circular',
      description: json['description']?.toString() ?? '',
      important: json['important'] == true || json['important'] == 1,
      createdAt: json['created_at']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
    );
  }
}
