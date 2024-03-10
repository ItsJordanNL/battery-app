import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Battery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var battery = Battery();
  int level = 100;
  BatteryState batteryState = BatteryState.full;
  late Timer timer;
  late StreamSubscription streamSubscription;

  // Additional properties for time estimation
  DateTime? lastUpdateTime;
  double drainingRate = 0; // percentage per millisecond

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

    if (batteryLevel == 100 && batteryState != BatteryState.full) {
      setState(() {
        batteryState = BatteryState.full;
      });
    }

    final now = DateTime.now();
    if (lastUpdateTime != null && batteryLevel != level) {
      final duration = now.difference(lastUpdateTime!);
      drainingRate = (level - batteryLevel) / duration.inMilliseconds;
    }

    level = batteryLevel;
    lastUpdateTime = now;

    setState(() {});
  }

  void getBatteryState() {
    streamSubscription = battery.onBatteryStateChanged.listen((state) {
      setState(() {
        batteryState = state;
      });
    });
  }

  // Calculate estimated time remaining in milliseconds
  int calculateTimeRemaining() {
    if (drainingRate > 0) {
      return level ~/ drainingRate;
    } else {
      return -1; // Indicate that the draining rate is not available
    }
  }

  // Format milliseconds into HH:mm:ss
  String formatTime(int milliseconds) {
    final Duration duration = Duration(milliseconds: milliseconds);
    return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    timer.cancel();
    super.dispose();
  }

  Widget buildBattery(BatteryState state, double animationValue) {
    Color textColor;

    if (level <= 10) {
      textColor = Colors.red;
    } else if (level <= 20) {
      textColor = Colors.orange;
    } else {
      switch (state) {
        case BatteryState.full:
          textColor = Colors.green;
          break;
        case BatteryState.charging:
          textColor = Colors.blue;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: CirclePainter(
                      color: textColor,
                      batteryLevel: level.toDouble(),
                    ),
                    child: const SizedBox(
                      width: 200,
                      height: 200,
                    ),
                  ),
                  Text(
                    '$level%',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                calculateChargingTimeRemaining() == -1
                    ? 'Calculating time until full...'
                    : 'Time until full: ${formatTime(calculateChargingTimeRemaining())}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ],
          );
        case BatteryState.discharging:
        default:
          textColor = Colors.grey;
          break;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              painter: CirclePainter(
                color: textColor,
                batteryLevel: level.toDouble(),
              ),
              child: const SizedBox(
                width: 200,
                height: 200,
              ),
            ),
            Text(
              '$level%',
              style: TextStyle(
                color: textColor,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          calculateTimeRemaining() == -1
              ? 'Calculating time until empty...'
              : 'Time until empty: ${formatTime(calculateTimeRemaining())}',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  int calculateChargingTimeRemaining() {
    if (drainingRate.isFinite && drainingRate < 0) {
      return (100 - level) ~/ -drainingRate;
    } else {
      return -1; // Charging rate not available or not a finite number
    }
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

    final grayPaint = Paint()
      ..color = Colors.grey.shade200 // Gray color for the unfilled part
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final sweepAngle = 360.0 * (batteryLevel / 100);

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      -90.0 * (pi / 180),
      sweepAngle * (pi / 180),
      false,
      paint,
    );

    // Draw the remaining unfilled part in gray
    final remainingAngle = 360.0 - sweepAngle;
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      -90.0 * (pi / 180) + sweepAngle * (pi / 180),
      remainingAngle * (pi / 180),
      false,
      grayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
