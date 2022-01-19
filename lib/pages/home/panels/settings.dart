import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import 'package:air_quality/pages/home/panels/bluetooth_management.dart';

/// A panel in the HomePage which provides app settings
class SettingsPanel extends StatefulWidget {
  const SettingsPanel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingsPanelState();
  }
}

class _SettingsPanelState extends State<SettingsPanel> {
  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      children: <Widget>[
        DropDownSettingsTile(
          title: "Temperature unit",
          settingKey: "temperature_unit",
          selected: 0,
          values: const <int, String>{0: 'Celsius', 1: 'Fahrenheit'},
        ),
        SettingsGroup(title: 'Device Info', children: <Widget>[
          SimpleSettingsTile(
            title: 'SW version',
            subtitle: '0.1.1',
          ),
          SimpleSettingsTile(
            title: 'Device name',
            subtitle: 'My Air-Checker',
          ),
          ElevatedButton(
          child: const Text('Bluetooth Devices Management'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  FlutterBlueApp()),
            );
          },
        ),

        ])

      ],
    );
  }
}
