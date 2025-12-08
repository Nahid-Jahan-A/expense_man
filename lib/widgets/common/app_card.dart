import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated card widget with Material 3 styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadiusGeometry? borderRadius;
  final bool animate;
  final int animationIndex;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
    this.animate = true,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget card = Card(
      elevation: elevation ?? 0,
      color: color ?? colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius as BorderRadius? ?? BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    if (animate) {
      return card
          .animate()
          .fadeIn(delay: Duration(milliseconds: 50 * animationIndex))
          .slideY(
            begin: 0.1,
            end: 0,
            delay: Duration(milliseconds: 50 * animationIndex),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
    }

    return card;
  }
}
