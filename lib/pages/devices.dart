import 'dart:convert';

import 'package:air_quality/models/connect_info.dart';
import 'package:air_quality/pages/home/panels/dashboard.dart';
import 'package:air_quality/widgets/air_quality_monitor.dart';
import 'package:air_quality/widgets/bluetooth_aqc.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

List<bool> isSelected = [false];
String connectDevId = '';
bool isConnected = false;
var logger = Logger();

class DevicePage extends StatefulWidget {
  DevicePage({Key? key, required this.title, required this.checker})
      : super(key: key);
  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};
  final BluetoothAqc checker;

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final _writeController = TextEditingController();
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = <BluetoothService>[];

  @override
  void initState() {
    super.initState();

    widget.checker.connect();
    widget.checker.isConnected();

    if (widget.checker.connectState == true) {
      isConnected = true;
      setState(() {
        //refresh
      });
    } else {
      isConnected = false;
      setState(() {
        //refresh
      });
    }

    widget.checker.state.listen((state) {
      if (state == AirQualityChecker.connected) {
        isConnected = true;
        setState(() {
          //refresh
        });
      } else if (state == AirQualityChecker.disconnected) {
        isConnected = false;
        setState(() {
          //refresh
        });
      }
    });

    widget.flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        widget.flutterBlue.scan();
      }
    });

    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceToList(device);
      }
    });

    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceToList(result.device);
        if (result.device.name == ConnectInfo().deviceID) {
          //Assigning bluetooth device
          var device = result.device;
          connect(device);
          //After that we stop the scanning for device
          stopScanning();
        }
      }
    });
  }

  _addDeviceToList(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      if (mounted) {
        setState(() {
          if (device.name != '') {
            widget.devicesList.add(device);
          }
        });
      }
    }
  }

  ListView _buildListViewOfDevices() {
    connectDevId = ConnectInfo().deviceID;

    List<Container> containers = <Container>[];
    for (BluetoothDevice device in widget.devicesList) {
      if (device.id.toString() == connectDevId) {
        if (isConnected == false) {
          //current state is disconnected, this is last connected device
          containers.insert(
            0,
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                            device.name == ''
                                ? '(unknown device)'
                                : device.name,
                            style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey)),
                        Text(device.id.toString(),
                            style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey)),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Row(
                    children: <Widget>[
                      OutlinedButton(
                        child: const Text(
                          'Connect Again',
                          style: TextStyle(color: Colors.lightBlueAccent),
                        ),
                        onPressed: () async {
                          connectDevId = device.id.toString();
                          ConnectInfo().deviceID = connectDevId;

                          try {
                            connectDevice(device);

                            device.state.listen((state) {
                              if (state == BluetoothDeviceState.disconnected) {
                                //Fluttertoast.showToast(msg: "Connect Failed");
                                logger.w("Connect Failed");
                              }
                            });
                          } catch (e) {
                            if (e != 'already_connected') {
                              rethrow;
                            }
                          } finally {
                            if (isConnected == true) {
                              _services = await device.discoverServices()
                                  .timeout(const Duration(seconds: 10), onTimeout: () => <BluetoothService>[]);
                            }
                          }
                          if (mounted) {
                            setState(() {
                              _connectedDevice = null;
                            });
                          }
                          setState(() {
                            //refresh
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          primary: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          side: const BorderSide(
                              width: 2, color: Colors.lightBlueAccent),
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            ),
          );
        } else {
          //current state is connected, and this is the connected device
          containers.insert(
            0,
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                            device.name == ''
                                ? '(unknown device)'
                                : device.name,
                            style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        Text(device.id.toString(),
                            style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey)),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Row(
                    children: <Widget>[
                      OutlinedButton(
                        child: const Text(
                          'Disconnect',
                          style: TextStyle(color: Colors.green),
                        ),
                        onPressed: () async {
                          connectDevId = '';
                          ConnectInfo().deviceID = connectDevId;
                          try {
                            device.disconnect();

                            device.state.listen((state) {
                              if (state == BluetoothDeviceState.connected) {
                                //Fluttertoast.showToast(msg: "Disconnect Failed");
                                logger.w("Disconnect Failed");
                              }
                            });
                          } catch (e) {
                            if (e != 'already_connected') {
                              rethrow;
                            }
                          } finally {
                            if (isConnected == true) {
                              _services = await device
                                  .discoverServices()
                                  .timeout(const Duration(seconds: 10), onTimeout: () => <BluetoothService>[]);
                            }
                          }
                          if (mounted) {
                            setState(() {
                              _connectedDevice = null;
                            });
                          }
                          setState(() {
                            //refresh
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          primary: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          side: const BorderSide(
                              width: 2, color: Colors.lightGreen),
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            ),
          );
        }
      } else {
        containers.add(
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(device.name == '' ? '(unknown device)' : device.name,
                          style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey)),
                      Text(device.id.toString(),
                          style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey)),
                    ],
                  ),
                ),
                Expanded(
                    child: Row(
                  children: <Widget>[
                    OutlinedButton(
                      child: const Text(
                        'Connect',
                        style: TextStyle(color: Colors.lightBlueAccent),
                      ),
                      onPressed: () async {
                        connectDevId = device.id.toString();
                        ConnectInfo().deviceID = connectDevId;

                        try {

                          connectDevice(device);

                          device.state.listen((state) {
                            if (state == BluetoothDeviceState.disconnected) {
                              //Fluttertoast.showToast(msg: "Connect Failed");
                              logger.i("Connect Failed");
                            }
                          });
                        } catch (e) {
                          if (e != 'already_connected') {
                            rethrow;
                          }
                        } finally {
                          if (isConnected == true) {
                            _services = await device.discoverServices()
                                .timeout(const Duration(seconds: 10), onTimeout: () => <BluetoothService>[]);
                          }
                        }
                        if (mounted) {
                          setState(() {
                            _connectedDevice = device;
                          });
                        }
                        setState(() {
                          //refresh
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        primary: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        side: const BorderSide(
                            width: 2, color: Colors.lightBlueAccent),
                      ),
                    ),
                  ],
                ))
              ],
            ),
          ),
        );
      }

      if (widget.devicesList.isEmpty) {
        containers.add(Container(
            height: 50,
            child: Row(children: const <Text>[
              Text(
                  "No devices available. Please check the status of bluetooth and try again.")
            ])));
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
              child: const Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  if (mounted) {
                    setState(() {
                      widget.readValues[characteristic.uuid] = value;
                    });
                  }
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
              child: const Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Write"),
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
                            child: const Text("Send"),
                            onPressed: () {
                              characteristic.write(
                                  utf8.encode(_writeController.value.text));
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: const Text("Cancel"),
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
              child:
                  const Text('NOTIFY', style: TextStyle(color: Colors.white)),
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
  Future<void> connectDevice(BluetoothDevice device) async {
      if(_connectedDevice!=device) {
        logger.i('already connect with ${_connectedDevice}, now disconnect it.');
        _connectedDevice?.disconnect();
      }
      await device.connect();

  }

  void checkConnectedDevices() async {
    logger.i(_connectedDevice?.name);
    _connectedDevice?.disconnect();
  }

  void scanForDevices() async {
    widget.flutterBlue.scan().listen((scanResult) async {
      if (scanResult.device.name == ConnectInfo().deviceID) {
        //Assigning bluetooth device
        var device = scanResult.device;
        connect(device);
      } else {
        //last connected device does not exist
        ConnectInfo().deviceID = '';
      }
    });
  }

  void stopScanning() {
    widget.flutterBlue.stopScan();
  }

  void connect(BluetoothDevice device) async {
    widget.checker.connect();
  }

  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(widget.title),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: RefreshIndicator(
          //  Start scanning for Bluetooth LE devices
          onRefresh: () => refresh(),
          //  List of Bluetooth LE devices
          child: _buildListViewOfDevices()));
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<BluetoothService>('_services', _services));
  }
}
