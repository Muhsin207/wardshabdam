class Program {
  final int id;
  final String title;
  final String description;
  final String photo;
  final String eventDate;

  Program({
    required this.id,
    required this.title,
    required this.description,
    required this.photo,
    required this.eventDate,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json["id"] is int ? json["id"] as int : int.tryParse('${json["id"]}') ?? 0,
      title: json["title"]?.toString() ?? "Untitled program",
      description: json["description"]?.toString() ?? "",
      photo: json["photo"]?.toString() ?? "",
      eventDate: json["event_date"]?.toString() ?? "",
    );
  }
}