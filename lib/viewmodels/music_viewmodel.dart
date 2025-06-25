import 'package:flutter/foundation.dart';
// Use aliases to resolve ambiguous imports
import '../models/music_recommendation.dart' as models;
import '../services/music_service.dart' as services;
import '../services/auth_service.dart';

class MusicViewModel extends ChangeNotifier {
  final services.MusicService _musicService = services.MusicService();
  final AuthService _authService = AuthService();

  List<models.MusicRecommendation> _recommendations = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchedSong = '';
  List<String> _searchHistory = [];

  List<models.MusicRecommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchedSong => _searchedSong;
  List<String> get searchHistory => _searchHistory;

  Future<void> getRecommendations(String songName) async {
    if (songName.trim().isEmpty) {
      _setError('Please enter a song name');
      return;
    }

    _setLoading(true);
    _clearError();
    _searchedSong = songName;
    _recommendations.clear();

    try {
      // Fix: Use class name for static method, not instance
      _recommendations = (await services.MusicService.getRecommendations(songName)).cast<models.MusicRecommendation>();

      if (_recommendations.isEmpty) {
        _setError('No recommendations found for "$songName"');
      } else {
        // Update search history - only if the method exists in AuthService
        if (_authService.currentUser != null) {
          // Option A: If you have updateSearchHistory method in AuthService
          // await _authService.updateSearchHistory(_authService.currentUser!.uid, songName);

          // Option B: Just update local history for now
          _addToSearchHistory(songName);
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _addToSearchHistory(String searchTerm) {
    if (!_searchHistory.contains(searchTerm)) {
      _searchHistory.insert(0, searchTerm);
      if (_searchHistory.length > 10) {
        _searchHistory.removeLast();
      }
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void clearRecommendations() {
    _recommendations.clear();
    _searchedSong = '';
    _clearError();
    notifyListeners();
  }
}