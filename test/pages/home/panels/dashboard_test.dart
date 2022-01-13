
import 'package:air_quality/models/air_quality.dart';
import 'package:air_quality/pages/home/panels/dashboard.dart';
import 'package:air_quality/widgets/air_quality_monitor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';

late AirQuality airQuality;

late _MockReader mockReader;

class _MockReader implements AirQualityChecker {
  int _co2 = 0;
  int _voc = 0;
  int _temperature = 0;
  int _humidity = 0;

  @override
  int readCO2() {
    return _co2;
  }

  @override
  int readHumidity() {
    return _humidity;
  }

  @override
  int readTemperature() {
    return _temperature;
  }

  @override
  int readVoc() {
    return _voc;
  }

  void setCO2(int co2) => _co2 = co2;

  void setVoc(int voc) => _voc = voc;

  void setTemperature(int temperature) => _temperature = temperature;

  void setHumidity(int humidity) => _humidity = humidity;
}

Widget _createDashboardPage() {
  mockReader = _MockReader();
  return ChangeNotifierProvider<AirQuality>(
      create: (context) {
        airQuality = AirQuality();
        return airQuality;
      },
      child: MaterialApp(home: DashboardPanel(checker: mockReader)));
}

void main() {
  group("[Home Page]-[Dashboard Panel] widget tests", () {
    testWidgets("Testing sensor info updating", (tester) async {
      await tester.pumpWidget(_createDashboardPage());
      airQuality.updateCO2(100);
      airQuality.updateVoc(200);
      airQuality.updateTemperature(32);
      airQuality.updateHumidity(60);
      await tester.pumpAndSettle();
      expect(find.text('100 PPM'), findsOneWidget);
      expect(find.text('200 PPM'), findsOneWidget);
      expect(find.text('32°C'), findsOneWidget);
      expect(find.text("60 %"), findsOneWidget);
    });

    testWidgets("Testing sensor info updating", (tester) async {
      await tester.pumpWidget(_createDashboardPage());
      mockReader.setCO2(300);
      mockReader.setVoc(200);
      mockReader.setTemperature(32);
      mockReader.setHumidity(60);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('300 PPM'), findsNothing);
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));
      expect(find.text('300 PPM'), findsOneWidget);
      expect(find.text('200 PPM'), findsOneWidget);
      expect(find.text('32°C'), findsOneWidget);
      expect(find.text("60 %"), findsOneWidget);
    });
  });
}
