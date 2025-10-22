import 'package:flutter/material.dart';

/// Widget skeleton loading với shimmer effect
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withOpacity(0.5),
                  theme.colorScheme.surface,
                ],
                stops: [
                  (_animation.value - 1).clamp(0.0, 1.0),
                  _animation.value.clamp(0.0, 1.0),
                  (_animation.value + 1).clamp(0.0, 1.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton loader cho task item
class TaskItemSkeleton extends StatelessWidget {
  const TaskItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Checkbox skeleton
              SkeletonLoader(
                width: 20,
                height: 20,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 12),
              // Title skeleton
              Expanded(
                child: SkeletonLoader(
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Priority indicator skeleton
              SkeletonLoader(
                width: 8,
                height: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description skeleton
          SkeletonLoader(
            height: 12,
            width: double.infinity * 0.7,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            height: 12,
            width: double.infinity * 0.5,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          // Tags and date skeleton
          Row(
            children: [
              SkeletonLoader(
                width: 60,
                height: 20,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 8),
              SkeletonLoader(
                width: 80,
                height: 20,
                borderRadius: BorderRadius.circular(10),
              ),
              const Spacer(),
              SkeletonLoader(
                width: 70,
                height: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader cho danh sách tasks
class TaskListSkeleton extends StatelessWidget {
  final int itemCount;

  const TaskListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const TaskItemSkeleton(),
    );
  }
}

/// Skeleton loader cho focus session item
class FocusSessionSkeleton extends StatelessWidget {
  const FocusSessionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon skeleton
          SkeletonLoader(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                SkeletonLoader(
                  height: 16,
                  width: double.infinity * 0.6,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                // Duration skeleton
                SkeletonLoader(
                  height: 12,
                  width: double.infinity * 0.4,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          // Time skeleton
          SkeletonLoader(
            width: 60,
            height: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader cho profile card
class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar skeleton
          SkeletonLoader(
            width: 80,
            height: 80,
            borderRadius: BorderRadius.circular(40),
          ),
          const SizedBox(height: 16),
          // Name skeleton
          SkeletonLoader(
            height: 20,
            width: 120,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          // Email skeleton
          SkeletonLoader(
            height: 14,
            width: 160,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 20),
          // Stats row skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  SkeletonLoader(
                    width: 40,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  SkeletonLoader(
                    width: 60,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              Column(
                children: [
                  SkeletonLoader(
                    width: 40,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  SkeletonLoader(
                    width: 60,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              Column(
                children: [
                  SkeletonLoader(
                    width: 40,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  SkeletonLoader(
                    width: 60,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

