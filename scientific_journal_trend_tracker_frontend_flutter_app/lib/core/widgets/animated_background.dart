import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Particle> _particles = List.generate(120, (index) => Particle());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..addListener(() {
        setState(() {
          for (var particle in _particles) {
            particle.update();
          }
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Grid Background
        Positioned.fill(
          child: CustomPaint(
            painter: GridPainter(),
          ),
        ),
        
        // 2. Floating Particles
        Positioned.fill(
          child: CustomPaint(
            painter: ParticlePainter(_particles),
          ),
        ),
        
        // 3. Main Content
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}

// Custom Painter for Grid Background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.15) // Fainter light gray grid
      ..strokeWidth = 1;
    
    const step = 40.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Particle class for 3D Bubble Effect
class Particle {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  // Slower vertical speed
  double speed = 0.00015 + Random().nextDouble() * 0.0005;
  double radius = 1 + Random().nextDouble() * 3;
  
  // Fainter Purple colors for tiny dots across all screens
  Color color = [
    const Color(0xFFD8B4E2).withValues(alpha: 0.2), // Light Purple
    const Color(0xFF8B5CF6).withValues(alpha: 0.15), // Purple
    const Color(0xFF6D28D9).withValues(alpha: 0.1), // Dark Purple
  ][Random().nextInt(3)];
  
  // Slower horizontal oscillation
  double oscillationSpeed = 0.003 + Random().nextDouble() * 0.01;
  double oscillationOffset = Random().nextDouble() * pi * 2;

  void update() {
    y -= speed;
    if (y < -0.1) {
      y = 1.1; // Reset to bottom
      x = Random().nextDouble();
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;
        
      // Add a slight horizontal sway to simulate 3D floating
      final sway = sin(DateTime.now().millisecondsSinceEpoch * p.oscillationSpeed * 0.001 + p.oscillationOffset) * 0.02;
      
      canvas.drawCircle(
        Offset((p.x + sway) * size.width, p.y * size.height), 
        p.radius, 
        paint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
