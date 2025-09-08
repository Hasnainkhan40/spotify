import 'package:flutter/material.dart';

class FancyFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData isIcon; // 👈 Define the icon field

  const FancyFAB({
    required this.onPressed,
    required this.isIcon, // 👈 Add to constructor
    super.key,
  });

  @override
  State<FancyFAB> createState() => _FancyFABState();
}

class _FancyFABState extends State<FancyFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff42C83C), Color(0xff42C83C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 6.28319, // 2 * pi radians = 360°
              child: child,
            );
          },
          child: Icon(widget.isIcon, color: Colors.white, size: 32), // ✅ fixed
        ),
      ),
    );
  }
}
