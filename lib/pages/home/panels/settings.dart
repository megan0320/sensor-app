import 'package:air_quality/models/connect_info.dart';
import 'package:air_quality/widgets/air_quality_monitor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import 'package:air_quality/pages/devices.dart';

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
          ElevatedButton.icon(
            icon: Icon(Icons.bluetooth),
            label: Text('Set Device'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'devices_page');
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.lightBlueAccent,
              shadowColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              side: BorderSide(width: 2, color: Colors.white),
            ),
          ),
        ])
      ],
    );
  }
}
