import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Frosted-glass panel. Place it over an [AmbientBackground] (or any colourful
/// content) and the backdrop blur will pick up the glow behind it.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;
  final double blur;
  final bool sheen;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 14,
    this.color,
    this.borderColor,
    this.blur = 22,
    this.sheen = true,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.glassFill,
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder,
              width: 0.8,
            ),
          ),
          child: sheen ? Stack(children: [child, _sheen(radius)]) : child,
        ),
      ),
    );
  }

  Widget _sheen(BorderRadius radius) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.glassHighlight, Colors.transparent],
              stops: const [0.0, 0.4],
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft aurora glow backdrop — gives the glass surfaces something to refract.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark;
    double o(double v) => dark ? v : v * 0.5;

    Widget glow(Alignment a, Color c, double opacity, double size) {
      return Align(
        alignment: a,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [c.withOpacity(o(opacity)), c.withOpacity(0)],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      );
    }

    return IgnorePointer(
      child: Stack(
        children: [
          glow(const Alignment(-1.1, -1.1), AppColors.primary, 0.28, 520),
          glow(const Alignment(1.15, -1.0), const Color(0xFF38BDF8), 0.18, 440),
          glow(const Alignment(-1.1, 1.1), const Color(0xFF34D399), 0.16, 420),
          glow(const Alignment(1.1, 1.15), const Color(0xFFA855F7), 0.20, 480),
          glow(Alignment.center, const Color(0xFFF472B6), 0.07, 700),
        ],
      ),
    );
  }
}
