import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_recommender/services/music_service.dart';
import 'package:music_recommender/views/home/settings_screen.dart';
import 'package:music_recommender/widgets/search_history_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'package:music_recommender/services/music_service.dart' show MusicRecommendation;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final PageController _carouselController = PageController(viewportFraction: 0.8);
  List<MusicRecommendation> _recommendations = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, int> _popularSearches = {};
  int _currentCarouselIndex = 0;

  // Animation Controllers
  late AnimationController _animationController;
  late AnimationController _searchPulseController;
  late AnimationController _floatingController;
  late AnimationController _carouselAnimationController;
  late AnimationController _playButtonController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _playButtonAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPopularSearches();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchPulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _carouselAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _carouselAnimationController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _carouselAnimationController, curve: Curves.bounceOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.linear),
    );

    _playButtonAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _playButtonController, curve: Curves.elasticOut),
    );

    // Start animations
    _animationController.forward();
    _searchPulseController.repeat(reverse: true);
    _floatingController.repeat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _carouselController.dispose();
    _animationController.dispose();
    _searchPulseController.dispose();
    _floatingController.dispose();
    _carouselAnimationController.dispose();
    _playButtonController.dispose();
    super.dispose();
  }

  Future<void> _loadPopularSearches() async {
    try {
      final popular = await MusicService.getPopularSearches(limit: 6);
      setState(() {
        _popularSearches = popular;
      });
    } catch (e) {
      print('Error loading popular searches: $e');
    }
  }

  Future<void> _searchSong() async {
    final songName = _searchController.text.trim();
    if (songName.isEmpty) {
      _showCustomSnackBar('Please enter a song name', Icons.warning_amber_rounded);
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _recommendations = [];
      _currentCarouselIndex = 0;
    });

    try {
      final recommendations = await MusicService.getRecommendations(songName);
      setState(() {
        _recommendations = recommendations.cast<MusicRecommendation>();
        _isLoading = false;
      });

      if (recommendations.isNotEmpty) {
        // Start carousel animation
        _carouselAnimationController.forward();
        _showCustomSnackBar('Found ${recommendations.length} recommendations!', Icons.music_note);
      } else {
        _showCustomSnackBar('No recommendations found', Icons.search_off);
      }

      _loadPopularSearches();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showCustomSnackBar('Error: $e', Icons.error_outline);
    }
  }

  Future<void> _launchSpotify(String songTitle, String artist) async {
    final query = Uri.encodeComponent('$songTitle $artist');
    final spotifyUrl = 'https://open.spotify.com/search/$query';
    final spotifyAppUrl = 'spotify:search:$query';

    try {
      // Try to open in Spotify app first
      if (await canLaunchUrl(Uri.parse(spotifyAppUrl))) {
        await launchUrl(Uri.parse(spotifyAppUrl));
      } else {
        // Fallback to web version
        await launchUrl(Uri.parse(spotifyUrl), mode: LaunchMode.externalApplication);
      }

      HapticFeedback.mediumImpact();
      _showCustomSnackBar('Opening in Spotify...', Icons.open_in_new);
    } catch (e) {
      _showCustomSnackBar('Could not open Spotify', Icons.error_outline);
    }
  }

  void _showCustomSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC1CC).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF800000), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[100],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  void _searchPopularSong(String songName) {
    _searchController.text = songName;
    _searchSong();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF800000), Color(0xFFFFC1CC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu and Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Welcome to HeArMe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value * 0.1,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Search Bar with Pulse Animation
                  AnimatedBuilder(
                    animation: _searchPulseController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1 + (_searchPulseController.value * 0.05)),
                              blurRadius: 10 + (_searchPulseController.value * 5),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search for your songs',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 24,
                            ),
                            suffixIcon: _isLoading
                                ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      const Color(0xFFFFC1CC)),
                                ),
                              ),
                            )
                                : IconButton(
                              icon: const Icon(Icons.mic, color: Colors.grey),
                              onPressed: _searchSong,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          onSubmitted: (_) => _searchSong(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5DC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Carousel Recommendations Section
                      if (_recommendations.isNotEmpty) _buildCarouselSection(),
                      if (_isLoading) _buildLoadingWidget(),
                      if (_recommendations.isEmpty && !_isLoading && _popularSearches.isNotEmpty)
                        _buildTrendingSection(),
                      const SizedBox(height: 30),
                      // Your Songs Section
                      _buildYourSongsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCarouselSection() {
    return AnimatedBuilder(
      animation: _carouselAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.queue_music,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Your Recommendations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Carousel
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      controller: _carouselController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentCarouselIndex = index;
                        });
                      },
                      itemCount: _recommendations.length,
                      itemBuilder: (context, index) {
                        return _buildCarouselItem(_recommendations[index], index);
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Carousel Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _recommendations.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentCarouselIndex == index ? 12 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _currentCarouselIndex == index
                              ? const Color(0xFF800000)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarouselItem(MusicRecommendation recommendation, int index) {
    final isCenter = _currentCarouselIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: isCenter ? 0 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF800000).withOpacity(0.8),
            const Color(0xFFFFC1CC).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isCenter ? 0.3 : 0.1),
            blurRadius: isCenter ? 15 : 8,
            offset: Offset(0, isCenter ? 8 : 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: MusicNotePainter(),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Song Title
                Text(
                  recommendation.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Artist
                Text(
                  recommendation.artist,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Rating and Duration
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Color(0xFFFFC1CC),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recommendation.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      color: Colors.white.withOpacity(0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recommendation.duration,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Play Button and Spotify Button
                Row(
                  children: [
                    // Play Button with Animation
                    AnimatedBuilder(
                      animation: _playButtonAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _playButtonAnimation.value,
                          child: GestureDetector(
                            onTap: () {
                              _playButtonController.forward().then((_) {
                                _playButtonController.reverse();
                              });
                              HapticFeedback.mediumImpact();
                              // Add your play logic here
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Color(0xFF800000),
                                size: 28,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    // Spotify Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _launchSpotify(recommendation.title, recommendation.artist),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1DB954), // Spotify green
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_video,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Open in Spotify',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Popular Badge
          if (recommendation.isPopular)
            Positioned(
              top: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Hot',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFFFFC1CC),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: Color(0xFFFFC1CC),
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Finding perfect recommendations...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Trending Now',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _popularSearches.length > 3 ? 3 : _popularSearches.length,
            itemBuilder: (context, index) {
              final entry = _popularSearches.entries.elementAt(index);
              return _buildTrendingItem(entry.key, entry.value, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingItem(String songName, int searchCount, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 200)),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _searchPopularSong(songName);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC1CC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _capitalizeWords(songName),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Trending Song',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A574),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$searchCount searches',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildYourSongsSection() {
    return Column(
      children: [
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your songs',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchHistoryWidget()),
            );
          },
          child: const Text(
            'View all',
            style: TextStyle(
              color: Color(0xFFFFC1CC),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
    const SizedBox(height: 20),
    Container(
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
    color: Colors.grey.withOpacity(0.2),
    ),
    ),
    child: Column(
    children: [
    AnimatedBuilder(
    animation: _floatingController,
    builder: (context, child) {
    return Transform.translate(
    offset: Offset(0, math.sin(_floatingController.value * 2 * math.pi) * 5),
    child: Icon(
    Icons.music_note,
    size: 48,
    color: Colors.grey[400],
    ),
    );
    },
    ),
    const SizedBox(height: 16),
      Text(
        'No songs searched yet',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Search for your favorite songs to see them here',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[500],
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          // Focus on search bar
          FocusScope.of(context).requestFocus(FocusNode());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC1CC),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Start Searching',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
    ),
    ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Home', true),
          _buildNavItem(Icons.search, 'Search', false),

          _buildNavItem(Icons.person_outline, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();

        if (label == 'Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        } else if (label == 'Search') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchHistoryWidget()),
          );
        }
        // Add navigation logic for 'Home' if needed
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFC1CC).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF800000) : Colors.grey[600],
                size: isActive ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF800000) : Colors.grey[600],
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

// Custom Painter for Music Note Background Pattern
class MusicNotePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw musical notes pattern
    final noteSize = 20.0;
    final spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw simple note shape
        canvas.drawCircle(Offset(x + noteSize / 2, y + noteSize), noteSize / 3, paint);
        canvas.drawLine(
          Offset(x + noteSize, y + noteSize),
          Offset(x + noteSize, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Music Recommendation Model (if not already defined)

