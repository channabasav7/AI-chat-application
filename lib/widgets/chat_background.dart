import 'package:flutter/material.dart';

class ChatBackground extends StatelessWidget {
  const ChatBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF07111C),
            Color(0xFF0B1B2D),
            Color(0xFF111827),
          ],
          stops: <double>[0.0, 0.52, 1.0],
        ),
      ),
      child: Stack(
        children: <Widget>[
          const _AmbientGlow(
            alignment: Alignment(-0.95, -0.85),
            color: Color(0xFF38BDF8),
            size: 260,
          ),
          const _AmbientGlow(
            alignment: Alignment(1.05, -0.45),
            color: Color(0xFF63E6BE),
            size: 220,
          ),
          child,
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[color.withValues(alpha: 0.22), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}
