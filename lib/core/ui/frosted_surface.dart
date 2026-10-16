import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Apple-style vibrancy. [blur] true → real BackdropFilter (use ONLY on static
/// overlays: sheets, controls, nav — never inside scrolling content). [blur]
/// false → a translucent fill only (cheap; for scroll contexts). Always
/// RepaintBoundary-wrapped so it never repaints its neighbors.
class FrostedSurface extends StatelessWidget {
  const FrostedSurface({
    super.key,
    required this.child,
    this.blur = true,
    this.opacity = 0.6,
    this.borderRadius,
  });
  final Widget child;
  final bool blur;
  final double opacity;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? BorderRadius.zero;
    final fill = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: opacity),
        borderRadius: r,
      ),
      child: child,
    );
    if (!blur) {
      return RepaintBoundary(
        child: ClipRRect(borderRadius: r, child: fill),
      );
    }
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: fill,
        ),
      ),
    );
  }
}

/// Frosted-glass *look* with zero per-frame cost: a static sheen gradient
/// over the surface color. Unlike [FrostedSurface] with blur on, nothing here
/// samples the pixels behind it, so it never repaints while content scrolls
/// underneath. Use for bars and headers that live over scrolling content.
class FakeFrost extends StatelessWidget {
  const FakeFrost({
    super.key,
    required this.child,
    this.borderRadius,
    this.opacity = 0.85,
    this.padding,
  });
  final Widget child;
  final BorderRadius? borderRadius;
  final double opacity;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? BorderRadius.zero;
    final base = AppColors.surface.withValues(alpha: opacity);
    return RepaintBoundary(
      // Shadow lives OUTSIDE the clip: inside, the rounded cut would eat it.
      // It paints once with the bar (never samples scrolling content).
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: r,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: r,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // Whisper of sheen up top, untouched surface below: the wash
                // was flattening dark art into grey. Edge light carries the
                // glass read instead.
                colors: [
                  Color.alphaBlend(Colors.white.withValues(alpha: 0.07), base),
                  base,
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 0.5,
              ),
            ),
            child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ),
        ),
      ),
    );
  }
}
