import 'package:flutter/material.dart';
import 'package:music_recommender/models/music_recommendation.dart';

class RecommendationCard extends StatelessWidget {
  final String title;
  final String artist;
  final String album;
  final String imageUrl;
  final double rating;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onPlay;
  final bool isLiked;

  const RecommendationCard({
    Key? key,
    required this.title,
    required this.artist,
    required this.album,
    required this.imageUrl,
    required this.rating,
    this.onTap,
    this.onLike,
    this.onPlay,
    this.isLiked = false, required MusicRecommendation recommendation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF2a2a2a),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Album artwork
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: const Color(0xFF1DB954),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 30,
                      );
                    },
                  )
                      : const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Song details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artist,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      album,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating.floor()
                                ? Icons.star
                                : (index < rating && rating % 1 != 0)
                                ? Icons.star_half
                                : Icons.star_border,
                            color: const Color(0xFF1DB954),
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                children: [
                  IconButton(
                    onPressed: onPlay,
                    icon: const Icon(
                      Icons.play_circle_filled,
                      color: Color(0xFF1DB954),
                      size: 32,
                    ),
                  ),
                  IconButton(
                    onPressed: onLike,
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}