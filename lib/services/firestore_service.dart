// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/music_recommendation.dart';

class SearchedSong {
  final String id;
  final String songName;
  final String userId;
  final DateTime searchedAt;
  final List<MusicRecommendation>? recommendations;
  final int recommendationCount;

  SearchedSong({
    required this.id,
    required this.songName,
    required this.userId,
    required this.searchedAt,
    this.recommendations,
    required this.recommendationCount,
  });

  factory SearchedSong.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<MusicRecommendation>? recommendations;
    if (data['recommendations'] != null) {
      recommendations = (data['recommendations'] as List)
          .map((item) => MusicRecommendation.fromJson(item))
          .toList();
    }

    return SearchedSong(
      id: doc.id,
      songName: data['songName'] ?? '',
      userId: data['userId'] ?? '',
      searchedAt: (data['searchedAt'] as Timestamp).toDate(),
      recommendations: recommendations,
      recommendationCount: data['recommendationCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'songName': songName,
      'userId': userId,
      'searchedAt': Timestamp.fromDate(searchedAt),
      'recommendations': recommendations?.map((rec) => rec.toJson()).toList(),
      'recommendationCount': recommendationCount,
    };
  }
}

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static CollectionReference get _searchedSongsCollection =>
      _firestore.collection('searched_songs');

  static CollectionReference get _userSearchHistoryCollection =>
      _firestore.collection('users');

  /// Store a searched song in Firestore
  static Future<void> storeSearchedSong({
    required String songName,
    List<MusicRecommendation>? recommendations,
  }) async {
    try {
      String? userId = _getCurrentUserId();
      if (userId == null) {
        // If no user is logged in, create an anonymous user
        userId = await _createAnonymousUser();
      }

      final searchedSong = SearchedSong(
        id: '', // Firestore will auto-generate
        songName: songName.trim(),
        userId: userId,
        searchedAt: DateTime.now(),
        recommendations: recommendations,
        recommendationCount: recommendations?.length ?? 0,
      );

      // Store in main searched_songs collection
      DocumentReference docRef = await _searchedSongsCollection.add(searchedSong.toFirestore());

      // Also store in user's personal search history
      await _storeInUserHistory(userId, songName, docRef.id, recommendations);

      print('Successfully stored searched song: $songName');
    } catch (e) {
      print('Error storing searched song: $e');
      throw Exception('Failed to store search: ${e.toString()}');
    }
  }

  /// Store search in user's personal history
  static Future<void> _storeInUserHistory(
      String userId,
      String songName,
      String searchId,
      List<MusicRecommendation>? recommendations,
      ) async {
    try {
      await _userSearchHistoryCollection
          .doc(userId)
          .collection('search_history')
          .add({
        'songName': songName,
        'searchId': searchId,
        'searchedAt': Timestamp.now(),
        'recommendationCount': recommendations?.length ?? 0,
        'hasRecommendations': recommendations != null && recommendations.isNotEmpty,
      });
    } catch (e) {
      print('Error storing user search history: $e');
    }
  }

  /// Get current user ID or null if not authenticated
  static String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Create anonymous user for guest sessions
  static Future<String> _createAnonymousUser() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      return userCredential.user!.uid;
    } catch (e) {
      throw Exception('Failed to create anonymous user: ${e.toString()}');
    }
  }

  /// Get user's search history
  static Future<List<SearchedSong>> getUserSearchHistory({int limit = 20}) async {
    try {
      String? userId = _getCurrentUserId();
      if (userId == null) return [];

      QuerySnapshot querySnapshot = await _userSearchHistoryCollection
          .doc(userId)
          .collection('search_history')
          .orderBy('searchedAt', descending: true)
          .limit(limit)
          .get();

      List<SearchedSong> searchHistory = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String searchId = data['searchId'];

        // Get the full search data from main collection
        DocumentSnapshot searchDoc = await _searchedSongsCollection.doc(searchId).get();
        if (searchDoc.exists) {
          searchHistory.add(SearchedSong.fromFirestore(searchDoc));
        }
      }

      return searchHistory;
    } catch (e) {
      print('Error getting user search history: $e');
      return [];
    }
  }

  /// Get all searched songs (admin/analytics purpose)
  static Future<List<SearchedSong>> getAllSearchedSongs({int limit = 50}) async {
    try {
      QuerySnapshot querySnapshot = await _searchedSongsCollection
          .orderBy('searchedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => SearchedSong.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting all searched songs: $e');
      return [];
    }
  }

  /// Get popular searches (most searched songs)
  static Future<Map<String, int>> getPopularSearches({int limit = 10}) async {
    try {
      QuerySnapshot querySnapshot = await _searchedSongsCollection.get();

      Map<String, int> songCounts = {};

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String songName = data['songName']?.toLowerCase() ?? '';

        if (songName.isNotEmpty) {
          songCounts[songName] = (songCounts[songName] ?? 0) + 1;
        }
      }

      // Sort by count and return top results
      var sortedEntries = songCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return Map.fromEntries(sortedEntries.take(limit));
    } catch (e) {
      print('Error getting popular searches: $e');
      return {};
    }
  }

  /// Delete a search record
  static Future<void> deleteSearchRecord(String searchId) async {
    try {
      await _searchedSongsCollection.doc(searchId).delete();
      print('Successfully deleted search record: $searchId');
    } catch (e) {
      print('Error deleting search record: $e');
      throw Exception('Failed to delete search: ${e.toString()}');
    }
  }

  /// Clear user's search history
  static Future<void> clearUserSearchHistory() async {
    try {
      String? userId = _getCurrentUserId();
      if (userId == null) return;

      QuerySnapshot querySnapshot = await _userSearchHistoryCollection
          .doc(userId)
          .collection('search_history')
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Successfully cleared user search history');
    } catch (e) {
      print('Error clearing search history: $e');
      throw Exception('Failed to clear search history: ${e.toString()}');
    }
  }

  /// Update search with recommendations (if they come later)
  static Future<void> updateSearchWithRecommendations(
      String searchId,
      List<MusicRecommendation> recommendations,
      ) async {
    try {
      await _searchedSongsCollection.doc(searchId).update({
        'recommendations': recommendations.map((rec) => rec.toJson()).toList(),
        'recommendationCount': recommendations.length,
        'updatedAt': Timestamp.now(),
      });
      print('Successfully updated search with recommendations');
    } catch (e) {
      print('Error updating search with recommendations: $e');
      throw Exception('Failed to update search: ${e.toString()}');
    }
  }

  /// Get search analytics
  static Future<Map<String, dynamic>> getSearchAnalytics() async {
    try {
      QuerySnapshot querySnapshot = await _searchedSongsCollection.get();

      int totalSearches = querySnapshot.docs.length;
      int searchesWithRecommendations = 0;
      int totalRecommendations = 0;
      Set<String> uniqueUsers = {};

      DateTime now = DateTime.now();
      DateTime weekAgo = now.subtract(const Duration(days: 7));
      int searchesThisWeek = 0;

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        uniqueUsers.add(data['userId'] ?? '');

        int recCount = data['recommendationCount'] ?? 0;
        if (recCount > 0) {
          searchesWithRecommendations++;
          totalRecommendations += recCount;
        }

        DateTime searchDate = (data['searchedAt'] as Timestamp).toDate();
        if (searchDate.isAfter(weekAgo)) {
          searchesThisWeek++;
        }
      }

      return {
        'totalSearches': totalSearches,
        'uniqueUsers': uniqueUsers.length,
        'searchesWithRecommendations': searchesWithRecommendations,
        'totalRecommendations': totalRecommendations,
        'searchesThisWeek': searchesThisWeek,
        'averageRecommendationsPerSearch':
        searchesWithRecommendations > 0 ? totalRecommendations / searchesWithRecommendations : 0,
      };
    } catch (e) {
      print('Error getting search analytics: $e');
      return {};
    }
  }
}