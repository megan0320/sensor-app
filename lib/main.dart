import 'dart:math';

import 'package:air_quality/models/connect_info.dart';
import 'package:air_quality/pages/devices.dart';
import 'package:air_quality/pages/home/home.dart';
import 'package:logger/logger.dart';

import 'package:air_quality/widgets/bluetooth_aqc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';

import 'models/air_quality.dart';

void main() {
  Settings.init();
  ConnectInfo.init().then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AirQuality>(
          create: (context) => AirQuality(),
        ),
        ChangeNotifierProvider<ConnectInfo>(
          create: (context) => ConnectInfo(),
        ),
      ],
      child: MaterialApp(
        title: 'Air Quality Checker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: 'home_page',
        routes: {
          'home_page': (context) => Consumer<ConnectInfo>(
                builder: (context, connectInfo, child) {
                  //logger.i("update home_page connectInfo is ${connectInfo.deviceID}");
                  return HomePage(
                    title: 'Air Master',
                    checker: BluetoothAqc(devID: connectInfo.deviceID),
                  );
                },
              ),

          'devices_page': (context) => Consumer<ConnectInfo>(
                builder: (context, connectInfo, child) {
                  return DevicePage(
                    title: 'Device Page',
                    checker: BluetoothAqc(devID: connectInfo.deviceID),
                  );
                },
              )
        },
      ),
    );
  }
}
