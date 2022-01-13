
import 'package:air_quality/models/air_quality.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AirQuality Provider Tests', () {
    var quality = AirQuality();

    test('Testing update of air quality measurement being recorded', () {
      var co2 = 1000;
      quality.updateCO2(co2);
      expect(quality.co2, co2);

      var voc = 2000;
      quality.updateVoc(voc);
      expect(quality.voc, voc);

      var temperature = 33;
      quality.updateTemperature(temperature);
      expect(quality.temperature, temperature);

      var humidity = 80;
      quality.updateHumidity(humidity);
      expect(quality.humidity, humidity);
    });
  });
}
