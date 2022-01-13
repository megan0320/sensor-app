import 'package:air_quality/pages/home/panels/dashboard.dart';
import 'package:air_quality/pages/home/panels/settings.dart';
import 'package:air_quality/widgets/air_quality_monitor.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _panelIndex = 0;

  final List _panels = [
    {'panel': DashboardPanel(checker: AirQualityChecker()), 'title': 'Air Quality'},
    {'panel': const SettingsPanel(), 'title': 'Settings'}
  ];

  void _selectPanel(int index) {
    setState(() {
      _panelIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(_panels[_panelIndex]['title']),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: _panels[_panelIndex]['panel']),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _panelIndex,
        iconSize: 32,
        items: const [
          BottomNavigationBarItem(
              label: 'Dashboard', icon: Icon(Icons.dashboard)),
          BottomNavigationBarItem(
              label: 'Settings', icon: Icon(Icons.settings)),
        ],
        onTap: _selectPanel,
      ),
    );
  }
}
