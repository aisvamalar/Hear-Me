// lib/models/music_recommendation.dart
class MusicRecommendation {
  final String id;
  final String title;
  final String artist;
  final String genre;
  final double rating;
  final String? imageUrl;
  final String? previewUrl;
  final DateTime createdAt;

  MusicRecommendation({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.rating,
    this.imageUrl,
    this.previewUrl,
    required this.createdAt,
  });

  // Add fromJson factory constructor
  factory MusicRecommendation.fromJson(Map<String, dynamic> json) {
    return MusicRecommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      genre: json['genre'] as String,
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      previewUrl: json['previewUrl'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'genre': genre,
      'rating': rating,
      'imageUrl': imageUrl,
      'previewUrl': previewUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Add copyWith method for convenience
  MusicRecommendation copyWith({
    String? id,
    String? title,
    String? artist,
    String? genre,
    double? rating,
    String? imageUrl,
    String? previewUrl,
    DateTime? createdAt,
  }) {
    return MusicRecommendation(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MusicRecommendation(id: $id, title: $title, artist: $artist, genre: $genre, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MusicRecommendation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}