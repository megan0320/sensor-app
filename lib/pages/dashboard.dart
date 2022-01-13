import 'package:air_quality/models/air_quality.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DashboardPageState();
  }
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AirQuality>(
        create: (context) => AirQuality(),
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
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
