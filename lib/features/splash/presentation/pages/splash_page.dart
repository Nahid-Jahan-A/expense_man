import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

/// Stunning animated splash screen
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotateAnimation;
  late Animation<double> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<double> _loaderFadeAnimation;
  late Animation<double> _pulseAnimation;

  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Main animation controller for sequential animations
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Pulse animation for icon glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Icon scale animation - bouncy entrance
    _iconScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5),
    ));

    // Icon rotation animation
    _iconRotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Title slide animation
    _titleSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Title fade animation
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    // Subtitle fade animation
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );

    // Loader fade animation
    _loaderFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 0.9, curve: Curves.easeOut),
      ),
    );

    // Pulse animation for glow effect
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _generateParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 6 + 2,
        speed: _random.nextDouble() * 0.3 + 0.1,
        opacity: _random.nextDouble() * 0.5 + 0.1,
      ));
    }
  }

  void _startAnimations() async {
    // Set system UI for immersive splash
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    await Future.delayed(const Duration(milliseconds: 300));
    _mainController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _pulseController.repeat(reverse: true);

    // Navigate to home after splash
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) {
      // Restore system UI
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      context.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _pulseController,
          _particleController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1C1B1F),
                        const Color(0xFF2D2A33),
                        const Color(0xFF1C1B1F),
                      ]
                    : [
                        const Color(0xFF6750A4),
                        const Color(0xFF7B68B8),
                        const Color(0xFF9580D1),
                      ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Animated particles
                ..._buildParticles(isDark),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated icon with glow
                      _buildAnimatedIcon(isDark),

                      const SizedBox(height: 32),

                      // App title
                      _buildAnimatedTitle(),

                      const SizedBox(height: 8),

                      // Subtitle
                      _buildAnimatedSubtitle(isDark),

                      const SizedBox(height: 48),

                      // Loading indicator
                      _buildLoadingIndicator(isDark),
                    ],
                  ),
                ),

                // Version text at bottom
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _loaderFadeAnimation,
                    child: Text(
                      'v1.0.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildParticles(bool isDark) {
    return _particles.map((particle) {
      final progress = _particleController.value;
      final y = (particle.y + progress * particle.speed) % 1.0;

      return Positioned(
        left: particle.x * MediaQuery.of(context).size.width,
        top: y * MediaQuery.of(context).size.height,
        child: Container(
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: particle.opacity * (1 - progress * 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: particle.opacity * 0.5),
                blurRadius: particle.size * 2,
                spreadRadius: particle.size * 0.5,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildAnimatedIcon(bool isDark) {
    return ScaleTransition(
      scale: _iconScaleAnimation,
      child: RotationTransition(
        turns: _iconRotateAnimation,
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFFD0BCFF),
                        const Color(0xFF9580D1),
                      ]
                    : [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.9),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? const Color(0xFFD0BCFF) : Colors.white)
                      .withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: (isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6750A4))
                      .withValues(alpha: 0.2),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Wallet icon
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 56,
                  color: isDark ? const Color(0xFF1C1B1F) : const Color(0xFF6750A4),
                ),
                // Small coin decoration
                Positioned(
                  right: 20,
                  top: 24,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF4CAF50),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1C1B1F) : const Color(0xFF6750A4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '৳',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return Transform.translate(
      offset: Offset(0, _titleSlideAnimation.value),
      child: FadeTransition(
        opacity: _titleFadeAnimation,
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFE8DEF8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: const Text(
            'Expense Manager',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSubtitle(bool isDark) {
    return FadeTransition(
      opacity: _subtitleFadeAnimation,
      child: Text(
        'Track • Save • Grow',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white.withValues(alpha: 0.8),
          letterSpacing: 3,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isDark) {
    return FadeTransition(
      opacity: _loaderFadeAnimation,
      child: SizedBox(
        width: 150,
        child: Column(
          children: [
            // Custom animated loading bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.8),
                ),
                minHeight: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Particle data class for floating animation
class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}
