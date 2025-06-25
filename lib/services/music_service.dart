// lib/services/music_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'firestore_service.dart'; // Import the Firestore service

class MusicRecommendation {
  final String title;
  final String artist;
  final String genre;
  final double rating;
  final String duration;
  final bool isPopular;
  final String? spotifyUrl;

  MusicRecommendation({
    required this.title,
    required this.artist,
    required this.genre,
    required this.rating,
    required this.duration,
    required this.isPopular,
    this.spotifyUrl,
  });

  factory MusicRecommendation.fromJson(Map<String, dynamic> json) {
    return MusicRecommendation(
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      genre: json['genre'] ?? 'Unknown',
      rating: (json['rating'] ?? 0.0).toDouble(),
      duration: json['duration'] ?? '0s',
      isPopular: json['isPopular'] ?? false,
      spotifyUrl: json['spotifyUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'genre': genre,
      'rating': rating,
      'duration': duration,
      'isPopular': isPopular,
      'spotifyUrl': spotifyUrl,
    };
  }
}

class MusicService {
  // Flask API configuration - Update this with your actual server IP
  static const String baseUrl = 'http://172.17.15.178:5000';
  static const Duration timeoutDuration = Duration(seconds: 15);

  /// Get music recommendations from Flask API and store search in Firestore
  static Future<List<MusicRecommendation>> getRecommendations(String songName) async {
    if (songName.trim().isEmpty) {
      throw Exception('Song name cannot be empty');
    }

    List<MusicRecommendation> recommendations = [];

    try {
      // First, store the search attempt in Firestore (before getting recommendations)
      await _storeSearchAttempt(songName);

      final response = await http.get(
        Uri.parse('$baseUrl/recommend?song=${Uri.encodeComponent(songName)}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        recommendations = _parseRecommendationsFromResponse(response.body);

        // Store the successful search with recommendations in Firestore
        await _storeSuccessfulSearch(songName, recommendations);

        return recommendations;
      } else if (response.statusCode == 404) {
        // Store the unsuccessful search (no recommendations found)
        await _storeUnsuccessfulSearch(songName, 'No recommendations found');
        throw Exception('No recommendations found for "$songName"');
      } else {
        // Store the failed search (server error)
        await _storeFailedSearch(songName, 'Server error: ${response.statusCode}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Store the failed search with error details
      await _storeFailedSearch(songName, e.toString());

      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Please check your connection.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Cannot connect to server. Please check if the server is running.');
      } else {
        throw Exception('Connection error: ${e.toString()}');
      }
    }
  }

  /// Store initial search attempt
  static Future<void> _storeSearchAttempt(String songName) async {
    try {
      await FirestoreService.storeSearchedSong(
        songName: songName,
        recommendations: null, // No recommendations yet
      );
      print('Stored search attempt for: $songName');
    } catch (e) {
      print('Failed to store search attempt: $e');
      // Don't throw error here, continue with the main search
    }
  }

  /// Store successful search with recommendations
  static Future<void> _storeSuccessfulSearch(
      String songName,
      List<MusicRecommendation> recommendations,
      ) async {
    try {
      await FirestoreService.storeSearchedSong(
        songName: songName,
        recommendations: null,
      );
      print('Stored successful search for: $songName with ${recommendations.length} recommendations');
    } catch (e) {
      print('Failed to store successful search: $e');
    }
  }

  /// Store unsuccessful search (no recommendations)
  static Future<void> _storeUnsuccessfulSearch(String songName, String reason) async {
    try {
      await FirestoreService.storeSearchedSong(
        songName: songName,
        recommendations: [], // Empty list indicates no recommendations
      );
      print('Stored unsuccessful search for: $songName - $reason');
    } catch (e) {
      print('Failed to store unsuccessful search: $e');
    }
  }

  /// Store failed search (error occurred)
  static Future<void> _storeFailedSearch(String songName, String error) async {
    try {
      // You could create a separate collection for failed searches if needed
      // For now, we'll store with empty recommendations and log the error
      await FirestoreService.storeSearchedSong(
        songName: songName,
        recommendations: null,
      );
      print('Stored failed search for: $songName - Error: $error');
    } catch (e) {
      print('Failed to store failed search: $e');
    }
  }

  /// Get user's search history from Firestore
  static Future<List<SearchedSong>> getUserSearchHistory({int limit = 20}) async {
    try {
      return await FirestoreService.getUserSearchHistory(limit: limit);
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  /// Get popular searches from Firestore
  static Future<Map<String, int>> getPopularSearches({int limit = 10}) async {
    try {
      return await FirestoreService.getPopularSearches(limit: limit);
    } catch (e) {
      print('Error getting popular searches: $e');
      return {};
    }
  }

  /// Clear user's search history
  static Future<void> clearSearchHistory() async {
    try {
      await FirestoreService.clearUserSearchHistory();
      print('Search history cleared successfully');
    } catch (e) {
      print('Error clearing search history: $e');
      throw Exception('Failed to clear search history: ${e.toString()}');
    }
  }

  /// Get search analytics
  static Future<Map<String, dynamic>> getSearchAnalytics() async {
    try {
      return await FirestoreService.getSearchAnalytics();
    } catch (e) {
      print('Error getting search analytics: $e');
      return {};
    }
  }

  /// Parse recommendations from Flask API response
  static List<MusicRecommendation> _parseRecommendationsFromResponse(String responseBody) {
    try {
      // Check if response indicates no recommendations
      if (responseBody.contains('No recommendations found')) {
        return [];
      }

      List<MusicRecommendation> recommendations = [];
      List<String> lines = responseBody.split('\n');

      for (String line in lines) {
        if (line.trim().isNotEmpty && RegExp(r'^\d+\.').hasMatch(line.trim())) {
          final recommendation = _parseRecommendationLine(line.trim());
          if (recommendation != null) {
            recommendations.add(recommendation);
          }
        }
      }

      return recommendations;
    } catch (e) {
      throw Exception('Failed to parse recommendations: ${e.toString()}');
    }
  }

  /// Parse a single recommendation line from Flask API response
  static MusicRecommendation? _parseRecommendationLine(String line) {
    try {
      // Parse format: "1. Song Name by Artist Name - URL"
      RegExp regex = RegExp(r'^(\d+)\.\s(.+?)\sby\s(.+?)\s-\s(https?.+)$');
      Match? match = regex.firstMatch(line);

      if (match != null) {
        String songTitle = match.group(2)?.trim() ?? '';
        String artistName = match.group(3)?.trim() ?? '';
        String url = match.group(4)?.trim() ?? '';
        int index = int.parse(match.group(1) ?? '1');

        return MusicRecommendation(
          title: songTitle,
          artist: artistName,
          genre: 'Recommended',
          rating: _calculateDynamicRating(index),
          duration: _generateMockDuration(index),
          isPopular: index <= 2, // Top 2 recommendations are marked as popular
          spotifyUrl: url,
        );
      }
    } catch (e) {
      print('Error parsing recommendation line: $line, Error: $e');
    }
    return null;
  }

  /// Calculate dynamic rating based on recommendation position
  static double _calculateDynamicRating(int index) {
    // Rating decreases slightly for lower positions
    return 4.5 + (0.4 * (1 - (index - 1) / 10));
  }

  /// Generate mock duration based on index
  static String _generateMockDuration(int index) {
    int seconds = 120 + (index * 15); // 2:00 + 15s per position
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Check if the Flask server is reachable
  static Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get server information
  static Future<Map<String, dynamic>> getServerInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/info'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get server info');
      }
    } catch (e) {
      throw Exception('Server info unavailable: ${e.toString()}');
    }
  }
}