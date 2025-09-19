import 'package:flutter/material.dart';

class IsActive extends StatefulWidget {
  final double size;
  final Color color;
  final EdgeInsetsGeometry padding;
  final bool withAnimation;
  final bool withGlow;
  final Duration animationDuration;

  const IsActive({
    super.key,
    this.size = 8,
    this.color = Colors.green,
    this.padding = const EdgeInsets.all(4),
    this.withAnimation = false,
    this.withGlow = false,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<IsActive> createState() => _IsActiveState();
}

class _IsActiveState extends State<IsActive>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    if (widget.withAnimation) {
      _controller = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      )..repeat(reverse: true);

      _animation = Tween<double>(
        begin: 0.8,
        end: 1.2,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    }
  }

  @override
  void dispose() {
    if (widget.withAnimation) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget indicator = Icon(
      Icons.circle,
      size: widget.size,
      color: widget.color,
    );

    // Add glow effect
    if (widget.withGlow) {
      indicator = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withAlpha(100),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: indicator,
      );
    }

    // Add animation
    if (widget.withAnimation) {
      indicator = ScaleTransition(scale: _animation, child: indicator);
    }

    return Padding(padding: widget.padding, child: indicator);
  }
}
