class GalleryPhoto {
  final int id;
  final String title;
  final String description;
  final String eventDate;
  final String photoUrl;

  const GalleryPhoto({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.photoUrl,
  });

  factory GalleryPhoto.fromJson(Map<String, dynamic> json) {
    return GalleryPhoto(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? 'Untitled photo',
      description: json['description']?.toString() ?? '',
      eventDate: json['event_date']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? '',
    );
  }
}
