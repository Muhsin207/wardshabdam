class DownloadDocument {
  final int id;
  final String title;
  final String category;
  final String description;
  final String fileUrl;

  const DownloadDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.fileUrl,
  });

  factory DownloadDocument.fromJson(Map<String, dynamic> json) {
    return DownloadDocument(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? 'Untitled document',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
    );
  }
}
