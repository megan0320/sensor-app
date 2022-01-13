import 'package:air_quality/pages/home/home.dart';

import 'package:air_quality/widgets/air_quality_monitor.dart';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:air_quality/flutter_blue.dart';

import 'models/air_quality.dart';

void main() {
  
    Settings.init();
    runApp(const MyApp());
    FlutterBlue flutterBlue = FlutterBlue.instance;
    
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
    // do something with scan results
        for (ScanResult r in results) {
            print('${r.device.name} found! rssi: ${r.rssi}');
        }
    });

    // Stop scanning
    flutterBlue.stopScan();


}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  
            
            
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AirQuality>(
        create: (context) => AirQuality(),
        child: MaterialApp(
          title: 'Air Quality Checker add bluetooth',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.

            primarySwatch: Colors.red,
          ),
          home: const HomePage(title: 'Air Quality add bluetooth'),
          
            
                
        )
    );
  }
}
