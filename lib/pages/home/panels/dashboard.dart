import 'package:air_quality/models/air_quality.dart';
import 'package:air_quality/widgets/air_quality_monitor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

FlutterBlue flutterBlue = FlutterBlue.instance;

/// A panel in HomePage which displays the info gathered from Air Quality Checker device
class DashboardPanel extends StatelessWidget {
  //final AirQualityChecker checker;

  const DashboardPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const <Widget>[
        Expanded(
          child: Overview(),
        ),
        Expanded(
          child: Dashboard(),
        ),
      ],
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AirQuality>(
      builder: (context, quality, child) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: DashboardItem(
                        label: quality.co2.toString() + ' PPM',
                        image: const AssetImage("images/ic_co2.png"),
                      ),
                    ),
                    Expanded(
                      child: DashboardItem(
                        label: quality.voc.toString() + ' PPM',
                        image: const AssetImage("images/ic_voc.png"),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: DashboardItem(
                        label: quality.temperature.toString() + '°C',
                        image: const AssetImage("images/ic_temperature.png"),
                      ),
                    ),
                    Expanded(
                      child: DashboardItem(
                        label: quality.humidity.toString() + ' %',
                        image: const AssetImage("images/ic_humidity.png"),
                      ),
                    ),
                  ],
                ),
              ),
            ]);
      },
    );
  }
}

class DashboardItem extends StatelessWidget {
  final String label;
  final AssetImage image;

  const DashboardItem({required this.label, required this.image, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ImageIcon(
            image,
            size: 100,
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

class Overview extends StatelessWidget {
  const Overview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Expanded(
              flex: 2,
              child: Image(
                image: AssetImage("images/ic_rating.png"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '目前CO2濃度過高，請留意通風，維持新鮮空氣。',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ));
  }
}
