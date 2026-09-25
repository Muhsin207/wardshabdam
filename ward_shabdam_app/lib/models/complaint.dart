class Complaint {
  final int id;
  final String category;
  final String description;
  final String ward;
  final String status;
  final String? photo;

  Complaint({
    required this.id,
    required this.category,
    required this.description,
    required this.ward,
    required this.status,
    this.photo,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json["id"] is int ? json["id"] as int : int.tryParse('${json["id"]}') ?? 0,
      category: json["category"]?.toString() ?? "Unknown",
      description: json["description"]?.toString() ?? "",
      ward: json["ward"]?.toString() ?? "Unknown",
      status: json["status"]?.toString() ?? "Pending",
      photo: json["photo"]?.toString(),
    );
  }
}