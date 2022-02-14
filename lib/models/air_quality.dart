import 'package:flutter/cupertino.dart';

/// The [AirQuality] class holds the latest air quality info gathered from Air Quality Checker device.
class AirQuality extends ChangeNotifier {
  int _co2 = 0;
  int _voc = 0;
  double _temperature = 0;
  int _humidity = 0;

  AirQuality();

  int get co2 {
    return _co2;
  }

  int get voc {
    return _voc;
  }

  double get temperature {
    return _temperature;
  }

  int get humidity {
    return _humidity;
  }

  /// Called by a AQC (Air Quality Checker) device to update the latest CO2 measurement
  void updateCO2(int concentration) {
    if (concentration != _co2) {
      _co2 = concentration;
      notifyListeners();
    }
  }

  /// Called by a AQC device to update the latest VOC measurement
  void updateVoc(int concentration) {
    if (concentration != _voc) {
      _voc = concentration;
      notifyListeners();
    }
  }

  /// Called by a AQC device to update the latest temperature measurement
  void updateTemperature(double temperature) {
    if (temperature != _temperature) {
      _temperature = temperature;
      notifyListeners();
    }
  }

  /// Called by a AQC device to update the latest humidity measurement
  void updateHumidity(int humidity) {
    if (humidity != _humidity) {
      _humidity = humidity;
      notifyListeners();
    }
  }
}
