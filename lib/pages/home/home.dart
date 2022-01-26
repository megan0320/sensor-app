import 'package:air_quality/pages/home/panels/dashboard.dart';
import 'package:air_quality/pages/home/panels/settings.dart';
import 'package:air_quality/widgets/air_quality_monitor.dart';
import 'package:flutter/material.dart';

import '../../flutter_blue.dart';

/// The Home page of the app. Including the following panels:
/// - Dashboard
/// - Settings
class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title, required this.checker})
      : super(key: key);

  final String title;

  final AirQualityChecker checker;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _panelIndex = 0;
  bool _noConnectTipShowed = false;
  late List _panels;

  void _selectPanel(int index) {
    setState(() {
      _panelIndex = index;
    });
  }

  /// Builds the notice displayed when the AQC device is not connected
  Widget _buildNoConnectionNotice(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Device not connected. Connect to your Air Master now?',
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'devices_page');
                  },
                  child: const Text('Go'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    var state = widget.checker.state.asBroadcastStream();
    state.listen((event) {
      if (event == AirQualityChecker.disconnected) {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return _buildNoConnectionNotice(context);
          },
        );
      }
    });

    widget.checker.connect();
  }

  @override
  Widget build(BuildContext context) {
    _panels = [
      {
        'panel': const DashboardPanel(),
        'title': 'Air Quality',
      },
      {
        'panel': const SettingsPanel(),
        'title': 'Settings',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_panels[_panelIndex]['title']),
      ),
        body: RefreshIndicator(
        //  Start scanning for Bluetooth LE devices
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: AirQualityMonitor(
          checker: widget.checker,
          duration: const Duration(seconds: 3),
          child: _panels[_panelIndex]['panel'],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _panelIndex,
        iconSize: 32,
        items: const [
          BottomNavigationBarItem(
            label: 'Dashboard',
            icon: Icon(Icons.dashboard),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(Icons.settings),
          ),
        ],
        onTap: _selectPanel,
      ),
    );
  }
}
