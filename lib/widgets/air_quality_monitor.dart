import 'dart:async';
import 'dart:math';

import 'package:air_quality/models/air_quality.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger();

/// The [AirQualityMonitor] class controls how the measurement of air quality is gathered from a Air Quality Checker device.
class AirQualityMonitor extends StatefulWidget {
  final Widget child;
  final AirQualityChecker checker;
  final Duration duration;

  const AirQualityMonitor(
      {required this.checker,
      this.duration = const Duration(seconds: 1),
      required this.child,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AirQualityMonitorState();
  }
}

class _AirQualityMonitorState extends State<AirQualityMonitor> {
  
  late AirQuality _airQuality;

  Timer? _timer;

  void _start() {
    if (_timer != null) {
      logger.w("Monitor already started");
      return;
    }

    _timer = Timer.periodic(widget.duration, (timer) async {

      int co2 = await widget.checker.readCO2();
      _airQuality.updateCO2(co2);

      int voc = await widget.checker.readVoc();
      _airQuality.updateVoc(voc);

      double temperature = await widget.checker.readTemperature();
      _airQuality.updateTemperature(temperature);

      int humidity = await widget.checker.readHumidity();
      _airQuality.updateHumidity(humidity);
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _airQuality = Provider.of<AirQuality>(context, listen: false);

    var state = widget.checker.state.asBroadcastStream();
    state.listen((event) {
      if (event == AirQualityChecker.connected) {
        _start();
      } else {
        _stop();
      }
    });

    return widget.child;
  }
}

/// The [AirQualityChecker] is a abstract class which defines the methods should be implemented by a Air Quality Checker.
///
abstract class AirQualityChecker {
  static const disconnected = 0;
  static const connected = 1;

  /// Reads the CO2 concentration value in PPM.
  Future<int> readCO2() async {
    return Random().nextInt(3000);
  }

  /// Reads the VOC concentration value in PPM.
  Future<int> readVoc() async {
    return Random().nextInt(3000);
  }

  /// Reads the temperature in degree Celsius.
  Future<double> readTemperature() async {
    return Random().nextDouble() * 50;
  }

  /// Reads the humidity in percentage.
  Future<int> readHumidity() async {
    return Random().nextInt(100);
  }

  /// Check the connected status of the device
  @Deprecated("The method should not be used")
  Future<bool> isConnected();

  /// Connects to the AQC device
  Future<bool> connect();

  /// Return the states in either [connected] or [disconnected]
  Stream<int> get state;
}
