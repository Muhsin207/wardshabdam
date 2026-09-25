class Announcement {
  final int id;
  final String title;
  final String description;
  final String photo;
  final String createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.photo,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json["id"] is int ? json["id"] as int : int.tryParse('${json["id"]}') ?? 0,
      title: json["title"]?.toString() ?? "Untitled announcement",
      description: json["description"]?.toString() ?? "",
      photo: json["photo"]?.toString() ?? "",
      createdAt: json["created_at"]?.toString() ?? "",
    );
  }
}