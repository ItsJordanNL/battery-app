import 'dart:async';

import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
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
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      getBatteryPercentage();
    });
  }

  void getBatteryPercentage() async {
    final batteryLevel = await battery.batteryLevel;

    this.level = batteryLevel;

    setState(() {});
  }

  void getBatteryState() {
    streamSubscription = battery.onBatteryStateChanged.listen((state) {
      setState(() {
        this.batteryState = state;
      });
    });
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    timer.cancel();
  }

  Widget BuildBattery(BatteryState state) {
    switch (state) {
      case BatteryState.full:
        return Container(
          child: Icon(
            Icons.battery_full,
            size: 200,
            color: Colors.green,
          ),
          width: 200,
          height: 200,
        );
      case BatteryState.charging:
        return Container(
          child:
              Icon(Icons.battery_charging_full, size: 200, color: Colors.blue),
          width: 200,
          height: 200,
        );
      case BatteryState.discharging:

      default:
        return Container(
          child: Icon(Icons.battery_alert, size: 200, color: Colors.grey),
          width: 200,
          height: 200,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BuildBattery(batteryState),
              Text(
                '${level} %',
                style: TextStyle(color: Colors.black, fontSize: 25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}