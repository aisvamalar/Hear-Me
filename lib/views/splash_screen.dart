import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _waveController;
  late AnimationController _textController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _waveAnimation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Wave animation controller
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Logo animations
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.6)),
    );

    // Wave animation
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Text animations
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.3, 1.0)),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Particle animation
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    // Start animations sequence
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    _waveController.repeat();
    _particleController.repeat();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Navigate to main app after splash
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _waveController.dispose();
    _textController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
              Color(0xFFf5576c),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles background
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_particleAnimation.value),
                  size: Size.infinite,
                );
              },
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo with sound waves
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoController, _waveController]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Sound wave rings
                              ...List.generate(3, (index) {
                                return Transform.scale(
                                  scale: 1.0 + (index * 0.3) + (_waveAnimation.value * 0.5),
                                  child: Opacity(
                                    opacity: (1.0 - _waveAnimation.value) * (1.0 - index * 0.2),
                                    child: Container(
                                      width: 120 + (index * 40),
                                      height: 120 + (index * 40),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              // Main logo container
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.headphones,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // App name with animation
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textOpacity,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.white, Colors.white70],
                                ).createShader(bounds),
                                child: const Text(
                                  'HearMe',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Feel the Music',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 80),

                  // Loading indicator
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textOpacity,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.7),
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.1);

    // Create floating particles
    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i * 0.07 + 0.1)) % size.width;
      final y = (size.height * 0.3 +
          math.sin(animationValue * 2 * math.pi + i) * 50 +
          (animationValue * size.height * 0.4)) % size.height;

      final radius = 2.0 + math.sin(animationValue * 4 * math.pi + i) * 1.5;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }

    // Draw music note particles
    final notePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final x = (size.width * (i * 0.12 + 0.05)) % size.width;
      final y = (size.height * 0.2 +
          math.cos(animationValue * 1.5 * math.pi + i) * 80 +
          (animationValue * size.height * 0.6)) % size.height;

      // Simple music note shape
      canvas.drawCircle(Offset(x, y), 8, notePaint);
      canvas.drawRect(
        Rect.fromLTWH(x + 6, y - 20, 2, 20),
        notePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}