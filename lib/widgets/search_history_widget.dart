import 'package:flutter/material.dart';
import '../services/music_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class SearchHistoryWidget extends StatefulWidget {
  const SearchHistoryWidget({super.key});

  @override
  State<SearchHistoryWidget> createState() => _SearchHistoryWidgetState();
}

class _SearchHistoryWidgetState extends State<SearchHistoryWidget> {
  List<SearchedSong> searchHistory = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final history = await MusicService.getUserSearchHistory(limit: 50);
      setState(() {
        searchHistory = history;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    try {
      await MusicService.clearSearchHistory();
      await _loadSearchHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Search history cleared successfully'),
            backgroundColor: AppColors.accentPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing history: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentPink,
      appBar: AppBar(
        backgroundColor: AppColors.accentPink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.backgroundLight),
          onPressed: () => Navigator.pop(context),
          splashRadius: 24,
        ),
        title: const Text(
          'Search History',
          style: TextStyle(
            color: AppColors.backgroundLight,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          if (searchHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.clear_all, color: AppColors.textLight),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.surfaceDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'Clear Search History',
                        style: TextStyle(
                          color: AppColors.backgroundLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      content: const Text(
                        'Are you sure you want to clear all search history?',
                        style: TextStyle(color: AppColors.textLight, fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _clearHistory();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentPink,
                            foregroundColor: AppColors.primaryMaroon,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                splashRadius: 24,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textLight),
              onPressed: _loadSearchHistory,
              splashRadius: 24,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPink),
          strokeWidth: 3,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline,
                size: 56,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error loading search history',
              style: TextStyle(
                color: AppColors.backgroundLight,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadSearchHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink,
                foregroundColor: AppColors.primaryMaroon,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primaryMaroon,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightBlueAccent.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.history,
                size: 80,
                color: AppColors.textLight.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No search history yet',
              style: TextStyle(
                color: AppColors.backgroundLight,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your searched songs will appear here',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSearchHistory,
      color: AppColors.accentPink,
      backgroundColor: AppColors.surfaceDark,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: searchHistory.length,
        itemBuilder: (context, index) {
          final search = searchHistory[index];
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: 1.0,
            child: _buildSearchHistoryItem(search),
          );
        },
      ),
    );
  }

  Widget _buildSearchHistoryItem(SearchedSong search) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryMaroon,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: search.recommendationCount > 0
              ? AppColors.accentPink.withOpacity(0.4)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: search.recommendations != null && search.recommendations!.isNotEmpty
              ? () => _showRecommendations(search)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: search.recommendationCount > 0
                          ? [AppColors.accentPink.withOpacity(0.3), AppColors.accentPink.withOpacity(0.1)]
                          : [AppColors.textLight.withOpacity(0.2), AppColors.textLight.withOpacity(0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    search.recommendationCount > 0
                        ? Icons.music_note_rounded
                        : Icons.search_off_rounded,
                    color: search.recommendationCount > 0
                        ? AppColors.accentPink
                        : AppColors.textLight,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        search.songName,
                        style: const TextStyle(
                          color: AppColors.backgroundLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Searched ${_formatDateTime(search.searchedAt)}',
                        style: TextStyle(
                          color: AppColors.textLight.withOpacity(0.8),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (search.recommendationCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentPink.withOpacity(0.3),
                                AppColors.accentPink.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${search.recommendationCount} recommendations',
                            style: TextStyle(
                              color: AppColors.accentPink,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          'No recommendations found',
                          style: TextStyle(
                            color: AppColors.textLight.withOpacity(0.6),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (search.recommendations != null && search.recommendations!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentPink.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: AppColors.accentPink,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRecommendations(SearchedSong search) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.primaryMaroon,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.textLight.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    Text(
                      'Recommendations',
                      style: TextStyle(
                        color: AppColors.backgroundLight,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'For "${search.songName}"',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${search.recommendations!.length} songs found',
                      style: TextStyle(
                        color: AppColors.accentPink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: search.recommendations!.length,
                  itemBuilder: (context, index) {
                    final recommendation = search.recommendations![index];
                    return _buildRecommendationItem(recommendation as MusicRecommendation, index + 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(MusicRecommendation recommendation, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: recommendation.spotifyUrl != null
              ? () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Open: ${recommendation.spotifyUrl}'),
                backgroundColor: AppColors.accentPink,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                action: SnackBarAction(
                  label: 'Copy',
                  textColor: AppColors.primaryMaroon,
                  onPressed: () {
                    // Add clipboard functionality here
                  },
                ),
              ),
            );
          }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: recommendation.isPopular
                          ? [Colors.orange[400]!, Colors.orange[600]!]
                          : [AppColors.accentPink.withOpacity(0.9), AppColors.accentPink.withOpacity(0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.backgroundLight,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recommendation.title,
                              style: const TextStyle(
                                color: AppColors.backgroundLight,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (recommendation.isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange[400],
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Popular',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.backgroundLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'by ${recommendation.artist}',
                        style: TextStyle(
                          color: AppColors.textLight.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 16, color: Colors.amber[600]),
                          const SizedBox(width: 6),
                          Text(
                            recommendation.rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: AppColors.textLight.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time_rounded, size: 16, color: AppColors.textLight.withOpacity(0.8)),
                          const SizedBox(width: 6),
                          Text(
                            recommendation.duration,
                            style: TextStyle(
                              color: AppColors.textLight.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (recommendation.spotifyUrl != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentPink.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: AppColors.accentPink,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}