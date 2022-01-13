import 'package:air_quality/models/air_quality.dart';
import 'package:air_quality/widgets/air_quality_monitor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A panel in HomePage which displays the info gathered from Air Quality Checker device 
class DashboardPanel extends StatefulWidget {
  final AirQualityChecker checker;
  const DashboardPanel({required this.checker, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DashboardPanelState();
  }
}

class _DashboardPanelState extends State<DashboardPanel> {
  @override
  Widget build(BuildContext context) {
    return AirQualityMonitor(
        checker: widget.checker,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const <Widget>[
            Overview(),
            Dashboard(),
          ],
        ));
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DashboardState();
  }
}

Widget _buildDashboard(AirQuality quality) {
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            DashboardItem(
              label: quality.co2.toString() + ' PPM',
              image: const AssetImage("images/ic_co2.png"),
            ),
            DashboardItem(
              label: quality.voc.toString() + ' PPM',
              image: const AssetImage("images/ic_voc.png"),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            DashboardItem(
              label: quality.temperature.toString() + '°C',
              image: const AssetImage("images/ic_temperature.png"),
            ),
            DashboardItem(
              label: quality.humidity.toString() + ' %',
              image: const AssetImage("images/ic_humidity.png"),
            )
          ],
        )
      ]);
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AirQuality>(
      builder: (context, quality, child) {
        return _buildDashboard(quality);
      },
    );
  }
}

class DashboardItem extends StatefulWidget {
  final String label;
  //final IconData icon;
  final AssetImage image;

  /* const DashboardItem({required this.label, required this.icon, Key? key})
      : super(key: key); */

  const DashboardItem({required this.label, required this.image, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DashboardItemState();
  }
}

class _DashboardItemState extends State<DashboardItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ImageIcon(
          widget.image,
          size: 100,
        ),
        Text(
          widget.label,
          style: const TextStyle(fontSize: 20, color: Colors.blue),
        )
      ],
    );
  }
}

class Overview extends StatefulWidget {
  const Overview({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OverviewState();
  }
}

class _OverviewState extends State<Overview> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Image(
              image: AssetImage("images/ic_rating.png"),
              width: 180,
              height: 180,
            ),
            Text(
              '目前CO2濃度過高，請留意通風，維持新鮮空氣。',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            )
          ],
        ));
  }
}
