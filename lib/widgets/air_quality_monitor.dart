import 'dart:async';

import 'package:air_quality/models/air_quality.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

/// The [AirQualityMonitor] class controls how the measurement of air quality is gathered from a Reader device.
class AirQualityMonitor extends StatefulWidget {
  final Widget child;
  final AirQualityChecker checker;
  final Duration duration;

  const AirQualityMonitor(
      {required this.checker,
      this.duration = const Duration(seconds: 3),
      required this.child,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AirQualityMonitorState();
  }
}

class _AirQualityMonitorState extends State<AirQualityMonitor> {
  //int _updateInterval = 0;
  late AirQuality _airQuality;
  //int _co2Value = 0;
  late Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(widget.duration, (timer) {
      _airQuality.updateCO2(widget.checker.readCO2());
      _airQuality.updateVoc(widget.checker.readVoc());
      _airQuality.updateTemperature(widget.checker.readTemperature());
      _airQuality.updateHumidity(widget.checker.readHumidity());
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    _airQuality = Provider.of<AirQuality>(context);

    return widget.child;
  }
}

/// The [AirQualityChecker] is a abstract class which defines the methods should be implemented by a Air Quality Checker.
/// 
/// Todo: will be marked as abstract later
class AirQualityChecker {
  int readCO2() {
    return 100;
  }

  int readVoc() {
    return 200;
  }

  int readTemperature() {
    return 50;
  }

  int readHumidity() {
    return 80;
  }
}
