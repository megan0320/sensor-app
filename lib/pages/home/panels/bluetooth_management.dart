import 'dart:convert';

import 'package:air_quality/pages/home/panels/dashboard.dart';
import 'package:air_quality/widgets/air_quality_monitor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:air_quality/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

import 'package:air_quality/widgets/air_quality_monitor.dart' as air_quality_monitor;

void main() => runApp(bleDeviceWidget());
List<bool> isSelected = [false];

String lastConnectedDevice='NONE';

class bleDeviceWidget extends StatelessWidget {

    @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Device Management',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: bleDevicePage(title: 'Device Management'),
  );
}

class bleDevicePage extends StatefulWidget {
  bleDevicePage({Key? key, required this.title}) : super(key: key);

  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _bleDevicePageState createState() => _bleDevicePageState();
}

class _bleDevicePageState extends State<bleDevicePage> {
  final _writeController = TextEditingController();
  BluetoothDevice? _connectedDevice;
   //late List<BluetoothService> _services;
  List<BluetoothService> _services = <BluetoothService>[];

  @override
  void initState() {
    super.initState();


    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }




  ListView _buildListViewOfDevices() {
    List<Container> containers = <Container>[];
    /*containers.add(
        Container(
            height: 50,
            child: Row(
              children:<Widget>[
                  ElevatedButton.icon(
                      icon: Icon(Icons.search),
                      label: Text("Scan Device"),
                      onPressed: () {
                        widget.flutterBlue.startScan();
                        
                        /*Fluttertoast.showToast(
                            msg: "Scan Device Successfully!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );*/
                      },
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.center,
                        primary: Colors.lightBlue,
                        shadowColor: Colors.blueAccent,
                      ),
                  )
              ]

            )
      )
    );*/


//
    int i=0;
    for (BluetoothDevice device in widget.devicesList) {
      if(device.name == '')//do not show devices that don't have a name
        continue;

      if(device.name.contains(lastConnectedDevice)){
        var index = widget.devicesList.indexOf(device);
        //widget.devicesList.insert(0, device);
        log('it is the device, idx is $index');

        containers.insert(0,
          Container(
            alignment:Alignment.center,
            width:  MediaQuery.of(context).size.width,
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(device.name == '' ? '(unknown device)' : device.name,style: TextStyle(fontSize: 16.0,fontWeight:FontWeight.bold,color: Colors.green)),
                      Text(device.id.toString(),style: TextStyle(fontSize: 12.0,fontWeight:FontWeight.normal,color: Colors.grey)),

                    ],
                  ),
                ),
                Expanded(
                    child: Row(
                      children: <Widget>[
                        OutlinedButton(
                          child: Text(
                            'Disconnect',
                            style: TextStyle(color: Colors.green),
                          ),
                          onPressed: () async {
                            log('onPressed Disconnect!');
                            try {
                              device.disconnect();

                              lastConnectedDevice='NONE';
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setString("lastConnectedDevice", "NONE");

                            } catch (e) {
                              /*if (e.code != 'already_connected') {
                                throw e;
                              }*/
                            } finally {
                              _services = device.discoverServices() as List<BluetoothService>;
                            }
                            setState(() {
                              _connectedDevice=null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            side: BorderSide(width: 2, color: Colors.lightGreen),
                          ),

                        ),


                      ],
                    )
                )



              ],
            ),
          ),
        );
      }
      else{
        log('this is not last connected device = ${device.name}');
        containers.add(
          Container(
            alignment:Alignment.center,
            width:  MediaQuery.of(context).size.width,
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(device.name == '' ? '(unknown device)' : device.name,style: TextStyle(fontSize: 16.0,fontWeight:FontWeight.bold,color: Colors.blueGrey)),
                      Text(device.id.toString(),style: TextStyle(fontSize: 12.0,fontWeight:FontWeight.normal,color: Colors.grey)),

                    ],
                  ),
                ),
                Expanded(
                    child: Row(

                      children: <Widget>[

                        OutlinedButton(

                          child: Text(
                            'Connect',
                            style: TextStyle(color: Colors.lightBlueAccent),
                          ),
                          onPressed: () async {
                            log('onPressed!');
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            widget.flutterBlue.stopScan();
                            ///
                            lastConnectedDevice=device.name;
                            await prefs.setString("lastConnectDevice", lastConnectedDevice);
                            log('lastConnectDevice = ${prefs.getString("lastConnectDevice")}');
                            ///
                            try {
                              device.connect();

                            } catch (e) {
                              /*if (e.code != 'already_connected') {
                                throw e;
                              }*/
                            } finally {
                              _services = device.discoverServices() as List<BluetoothService>;
                            }
                            setState(() {
                              _connectedDevice = device;


                            });


                          },
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            side: BorderSide(width: 2, color: Colors.lightBlueAccent),
                          ),

                        ),


                      ],
                    )
                )

              ],
            ),
          ),
        );
        i++;
      }

      if(widget.devicesList.isEmpty){
        containers.add(
            Container(
                height: 50,
                child: Row(
                    children:<Text>[
                      Text("No devices available. Please check the status of bluetooth and try again.")
                    ]
                )
            )
        );
      }
    }




    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = <ButtonTheme>[];

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              color: Colors.blue,
              child: Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  setState(() {
                    widget.readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.read();
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Write"),
                        content: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _writeController,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Send"),
                            onPressed: () {
                              characteristic.write(
                                  utf8.encode(_writeController.value.text));
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                characteristic.value.listen((value) {
                  widget.readValues[characteristic.uuid] = value;
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  ListView _buildConnectDeviceView() {
    List<Container> containers = <Container>[];


    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = <Widget>[];

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Value: ' +
                        widget.readValues[characteristic.uuid].toString()),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        Container(
          child: ExpansionTile(
              title: Text(service.uuid.toString()),
              children: characteristicsWidget),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() {

    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: RefreshIndicator(
      //  Start scanning for Bluetooth LE devices
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),

        //  List of Bluetooth LE devices
        child: _buildView()


    )

  );
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<BluetoothService>('_services', _services));
  }
}

