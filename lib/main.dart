import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(BubbleApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}

class BubbleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BubbleScreen(),
    );
  }
}

class BubbleScreen extends StatefulWidget {
  @override
  _BubbleScreenState createState() => _BubbleScreenState();
}

class _BubbleScreenState extends State<BubbleScreen> {
  List<Bubble> bubbles = [];

  void generateBubbles(BuildContext context) {
    // Generate between 10 and 20 bubbles with random sizes and colors
    int numBubbles = Random().nextInt(11) + 10;
    for (int i = 0; i < numBubbles; i++) {
      double size = Random().nextDouble() * 50 + 20;
      Color color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
      Offset position = Offset(
        Random().nextDouble() * MediaQuery.of(context).size.width,
        Random().nextDouble() * MediaQuery.of(context).size.height,
      );
      Offset velocity = Offset(
        Random().nextDouble() * 6 - 3,
        Random().nextDouble() * 6 - 3,
      );
      Bubble bubble = Bubble(
          size: size, color: color, position: position, velocity: velocity);
      bubbles.add(bubble);
    }
  }

  @override
  void initState() {
    super.initState();

    // Generate bubbles when the screen is first loaded
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      generateBubbles(context);
      _startAnimation();
    });
  }

  void _startAnimation() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _updateBubbles();
      _startAnimation();
    });
  }

  void _updateBubbles() {
    setState(() {
      // Update the position of each bubble based on its velocity
      for (Bubble bubble in bubbles) {
        bubble.position += bubble.velocity;
        if (bubble.position.dx < -bubble.size) {
          bubble.position = Offset(
              MediaQuery.of(context).size.width + bubble.size,
              bubble.position.dy);
        } else if (bubble.position.dx >
            MediaQuery.of(context).size.width + bubble.size) {
          bubble.position = Offset(-bubble.size, bubble.position.dy);
        }
        if (bubble.position.dy < -bubble.size) {
          bubble.position = Offset(bubble.position.dx,
              MediaQuery.of(context).size.height + bubble.size);
        } else if (bubble.position.dy >
            MediaQuery.of(context).size.height + bubble.size) {
          bubble.position = Offset(bubble.position.dx, -bubble.size);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (TapDownDetails details) {
          // Find the bubble that was tapped and remove it
          for (int i = 0; i < bubbles.length; i++) {
            Bubble bubble = bubbles[i];
            if (bubble.contains(details.localPosition)) {
              setState(() {
                bubbles.removeAt(i);
              });
              break;
            }
          }

          // Check if there are any bubbles left
          if (bubbles.isEmpty) {
            // If there are no bubbles left, generate new ones
            generateBubbles(context);
          }
        },
        child: CustomPaint(
          painter: BubblePainter(bubbles),
          child: Container(),
        ),
      ),
    );
  }
}

class Bubble {
  Offset position;
  Offset velocity;
  double size;
  Color color;

  Bubble(
      {required this.size,
      required this.color,
      required this.position,
      required this.velocity});

  bool contains(Offset point) {
// Determine whether the bubble contains the given point
    double distance = (position - point).distance;
    return distance < size / 2;
  }
}

class BubblePainter extends CustomPainter {
  List<Bubble> bubbles;

  BubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    for (Bubble bubble in bubbles) {
// Draw each bubble on the canvas
      Paint paint = Paint()..color = bubble.color;
      canvas.drawCircle(bubble.position, bubble.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
