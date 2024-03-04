import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var battery = Battery();
  int level = 100;
  BatteryState batteryState = BatteryState.full;
  late Timer timer;
  late StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();
    getBatteryPercentage();
    getBatteryState();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getBatteryPercentage();
    });
  }

  void getBatteryPercentage() async {
    final batteryLevel = await battery.batteryLevel;

    level = batteryLevel;

    setState(() {});
  }

  void getBatteryState() {
    streamSubscription = battery.onBatteryStateChanged.listen((state) {
      setState(() {
        batteryState = state;
      });
    });
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    timer.cancel();
    super.dispose();
  }

  Widget buildBattery(BatteryState state, double animationValue) {
    Color textColor = Colors.black;

    switch (state) {
      case BatteryState.full:
        textColor = Colors.green;
        break;
      case BatteryState.charging:
        textColor = Colors.blue;
        break;
      case BatteryState.discharging:
      default:
        textColor = Colors.grey;
        break;
    }

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: ColorTween(begin: textColor, end: textColor),
      builder: (context, dynamic color, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              painter: CirclePainter(
                color: color, // Adjusted to use animated color
                batteryLevel: level.toDouble(),
              ),
              child: const SizedBox(
                width: 200,
                height: 200,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$level%',
                  style: TextStyle(
                    color: color,
                    fontSize: 50, // Adjusted to use animated color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            buildBattery(batteryState, level.toDouble()),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Color color;
  final double batteryLevel;

  CirclePainter({required this.color, required this.batteryLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final sweepAngle = 360.0 * (batteryLevel / 100); // Adjusted here

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      -90.0 * (pi / 180), // startAngle
      sweepAngle * (pi / 180), // sweepAngle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}