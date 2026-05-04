import 'package:flutter/material.dart';

/// Reusable staggered entrance animation mixin.
/// Provides a lightweight way to animate children appearing one-by-one.
/// Each item slides up + fades in with a small delay between them.
mixin StaggeredListMixin<T extends StatefulWidget> on State<T>,
    TickerProviderStateMixin<T> {
  late AnimationController _staggerController;
  final List<Animation<double>> _fadeAnimations = [];
  final List<Animation<Offset>> _slideAnimations = [];

  /// Call in initState after super.initState()
  void initStagger({required int itemCount, int delayMs = 60}) {
    final totalDuration = 350 + (itemCount * delayMs);
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDuration),
    );

    for (int i = 0; i < itemCount; i++) {
      final startFraction = (i * delayMs) / totalDuration;
      final endFraction =
          ((i * delayMs) + 350).clamp(0, totalDuration) / totalDuration;

      _fadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(startFraction, endFraction, curve: Curves.easeOut),
          ),
        ),
      );

      _slideAnimations.add(
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(startFraction, endFraction,
                curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    _staggerController.forward();
  }

  /// Replay the stagger animation (e.g. after data refresh)
  void replayStagger() {
    _staggerController.forward(from: 0.0);
  }

  void disposeStagger() {
    _staggerController.dispose();
  }

  /// Wrap a child widget at given index with stagger animation
  Widget staggerItem(int index, Widget child) {
    if (index >= _fadeAnimations.length) return child;
    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: child,
      ),
    );
  }
}

/// A simple widget that animates its child sliding up + fading in on first build.
/// Perfect for wrapping individual items or sections.
class AnimateIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideFrom;

  const AnimateIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 350),
    this.slideFrom = const Offset(0, 0.05),
  });

  @override
  State<AnimateIn> createState() => _AnimateInState();
}

class _AnimateInState extends State<AnimateIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slide = Tween<Offset>(begin: widget.slideFrom, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: widget.child,
      ),
    );
  }
}

/// Wrap a widget to scale-bounce on tap (for interactive feedback like category/wallet items)
class TapBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const TapBounce({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.95,
  });

  @override
  State<TapBounce> createState() => _TapBounceState();
}

class _TapBounceState extends State<TapBounce>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
