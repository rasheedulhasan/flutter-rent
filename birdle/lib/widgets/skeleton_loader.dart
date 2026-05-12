import 'package:flutter/material.dart';
import 'package:birdle/core/app_theme.dart';

/// Skeleton loader widget for loading states.
/// Provides shimmer animation effect.
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                isDark ? AppTheme.shimmerBaseDark : AppTheme.shimmerBaseLight,
                isDark ? AppTheme.shimmerHighlightDark : AppTheme.shimmerHighlightLight,
                isDark ? AppTheme.shimmerBaseDark : AppTheme.shimmerBaseLight,
              ],
              stops: [
                0.0,
                (1.0 + _animation.value) / 4,
                1.0,
              ],
              begin: Alignment(-1.0 + _animation.value, 0),
              end: Alignment(1.0 + _animation.value, 0),
            ),
          ),
        );
      },
    );
  }
}

/// Card skeleton for list loading states.
class CardSkeleton extends StatelessWidget {
  final int itemCount;

  const CardSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.borderDark
                    : AppTheme.borderLight,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SkeletonLoader(width: 40, height: 40, borderRadius: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonLoader(width: 150, height: 14),
                          SizedBox(height: 6),
                          SkeletonLoader(width: 100, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SkeletonLoader(height: 10),
                const SizedBox(height: 6),
                const SkeletonLoader(width: 120, height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashboard stat card skeleton.
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.borderDark
              : AppTheme.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonLoader(width: 80, height: 12),
          SizedBox(height: 12),
          SkeletonLoader(width: 100, height: 24),
          SizedBox(height: 8),
          SkeletonLoader(width: 60, height: 10),
        ],
      ),
    );
  }
}
