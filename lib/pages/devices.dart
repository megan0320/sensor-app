import 'package:air_quality/models/connect_info.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:logger/logger.dart';

List<bool> isSelected = [false];
String connectDevId = '';
var logger = Logger();

enum ConnectStatus { disconnected, connected, connecting }

class DevicePage extends StatefulWidget {
  DevicePage({Key? key, required this.title}) : super(key: key);

  static const int scanTime = 10;
  static const int connectTime = 10;

  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  var currentConnectStatus = ConnectStatus.disconnected;
  bool isScanning = false;
  final List<BluetoothDevice> connectedDevicesList = <BluetoothDevice>[];
  final List<BluetoothDevice> disconnectedDevicesList = <BluetoothDevice>[];

  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = <BluetoothService>[];
  static const esServiceUuid = '0000181A-0000-1000-8000-00805F9B34FB';
  late ConnectInfo _connectInfo;

  @override
  void initState() {
    super.initState();

    _connectInfo = Provider.of<ConnectInfo>(context, listen: false);

    widget.flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        scanForDevices();
      }
    });

    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceToList(device, true);
      }
    });

    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        //logger.v("scan device addr = ${result.device.id}");
        _addDeviceToList(result.device, false);
      }
    });
  }

  _addDeviceToList(final BluetoothDevice device, bool isConnected) {
    //logger.v("_addDeviceToList device ${device.name} : ${device.id}");
    if (device.name != '') {
        if (mounted) {
          setState(() {
            if (isConnected) {
              if (!widget.connectedDevicesList.contains(device)) {
                widget.connectedDevicesList.add(device);
                if (widget.disconnectedDevicesList.contains(device)) {
                  widget.disconnectedDevicesList.remove(device);
                }
              }
            } else {
              if (!widget.disconnectedDevicesList.contains(device)) {
                widget.disconnectedDevicesList.add(device);
                if (widget.connectedDevicesList.contains(device)) {
                  widget.connectedDevicesList.remove(device);
                }
              }
            }
          });
        }
    }
  }

  ListView _buildListViewOfDevices() {
    connectDevId = _connectInfo.deviceID;
    //logger.i("get connect info in _buildListViewOfDevices, that device id is ${connectDevId}");

    List<Container> containers = <Container>[];

    for (BluetoothDevice device
        in widget.disconnectedDevicesList+widget.connectedDevicesList  ) {
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
                    RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text: device.name == ''
                                ? '(unknown device)'
                                : device.name,
                            style: (widget.connectedDevicesList.contains(device)
                                ? const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightGreen)
                                : const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)))),
                    RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text: device.id.toString(),
                            style: (widget.connectedDevicesList.contains(device)
                                ? const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.lightGreen)
                                : const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.blue)))),
                  ],
                ),
              ),
              Expanded(
                  child: Row(
                children: <Widget>[
                  OutlinedButton(
                      child: (widget.connectedDevicesList.contains(device)
                          ? const Text(
                              'Disconnect',
                              style: TextStyle(color: Colors.lightGreen),
                            )
                          : const Text(
                              'Connect',
                              style: TextStyle(color: Colors.blue),
                            )),
                      onPressed: (widget.connectedDevicesList.contains(device)
                          ? () async {
                              disconnectDevice(device);
                            }
                          : () async {
                              connectDevice(device);
                            }),
                      style: (widget.connectedDevicesList.contains(device)
                          ? OutlinedButton.styleFrom(
                              primary: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              side: const BorderSide(
                                  width: 2, color: Colors.lightGreen),
                            )
                          : OutlinedButton.styleFrom(
                              primary: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              side: const BorderSide(
                                  width: 2, color: Colors.blue),
                            ))),
                ],
              ))
            ],
          ),
        ),
      );
    }

    if (widget.connectedDevicesList.isEmpty &&
        widget.disconnectedDevicesList.isEmpty) {
      containers.add(Container(
          height: 50,
          child: Row(children: const <Text>[
            Text("No devices available. Please try again.")
          ])));
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  void disconnectDevice(BluetoothDevice device) async {
    connectDevId = '';
    _connectInfo.deviceID = connectDevId;
    device.disconnect();
  }

  void connectDevice(BluetoothDevice device) async {
    connectDevId = device.id.toString();
    _connectInfo.deviceID = connectDevId;

    //logger.i('want to connect with ${_connectInfo.deviceID}');

    if (_connectedDevice != device || _connectedDevice == null) {
      //logger.i('already connect with $_connectedDevice, now disconnect it.');
      _connectedDevice?.disconnect();
    }

    try {
      device.connect(timeout: const Duration(seconds: DevicePage.connectTime));
    } catch (e) {
      logger.w("Connect exception: $e");
    }

    device.state.listen((state) {
      if (state == BluetoothDeviceState.connected) {
        //logger.i("Connect Successfully");

        device.discoverServices().then((services) {
          _services = services;
          if (mounted) {
            setState(() {
              _connectedDevice = device;
              widget.currentConnectStatus = ConnectStatus.connected;

              //logger.i('want to connect with ${_connectInfo.deviceID}');
              _addDeviceToList(device, true);
            });
          }
        });
      } else if (state == BluetoothDeviceState.disconnected) {
        if (mounted) {
          setState(() {
            _connectedDevice = null;
            widget.currentConnectStatus = ConnectStatus.disconnected;

            //logger.i('want to disconnectDevice with ${_connectInfo.deviceID}');
            _addDeviceToList(device, false);
          });
        }
      }
    });
  }

  void scanForDevices() {
    if (widget.isScanning == false) {
      widget.isScanning = true;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Scanning ..."),
        backgroundColor: Colors.blueAccent,
      ));
      widget.flutterBlue
          .startScan(timeout: const Duration(seconds: DevicePage.scanTime))
          .whenComplete(() => widget.isScanning = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void stopScanning() {
    widget.flutterBlue.stopScan();
  }

  void connect() async {
    var devID = _connectInfo.deviceID;

    if (devID.isEmpty) {
      logger.w("Can not connect due to device ID not specified.");
      widget.currentConnectStatus = ConnectStatus.disconnected;
    }

    List<BluetoothDevice> devices = await widget.flutterBlue.connectedDevices;
    BluetoothDevice? targetDevice;

    if (devices.isNotEmpty) {
      for (BluetoothDevice device in devices) {
        if (device.id.toString() == devID) {
          targetDevice = device;
          widget.currentConnectStatus = ConnectStatus.connected;
          break;
        }
      }
    }

    if (targetDevice != null) {
      logger.i("Connect to ${targetDevice.name} [${targetDevice.id}}}]");

      // a connect is required (even the device is reported connected) to ensure
      // the underlying Bluetooth GATT components are working
      try {
        targetDevice.connect(
            timeout: const Duration(seconds: DevicePage.connectTime));
      } catch (e) {
        logger.w("Connect exception: $e");
      }

      targetDevice.state.listen((state) async {
        logger.i("Device state changed to $state");
        switch (state) {
          case BluetoothDeviceState.connected:
            logger.i("Device connected");
            List<BluetoothService> services =
                await targetDevice!.discoverServices();
            var essService = _findEssService(services);
            if (essService != null) {
              widget.currentConnectStatus = ConnectStatus.connected;
            } else {
              logger.e("ESS service not found!");
              widget.currentConnectStatus = ConnectStatus.disconnected;
            }
            break;
          case BluetoothDeviceState.disconnected:
            logger.i("Device disconnected");
            widget.currentConnectStatus = ConnectStatus.disconnected;
            break;
          default:
        }
      });
    } else {
      widget.currentConnectStatus = ConnectStatus.disconnected;
    }
  }

  /// Finds Environment Sensing Service in the given service list
  BluetoothService? _findEssService(List<BluetoothService> services) {
    for (BluetoothService service in services) {
      if (service.uuid.toString().toUpperCase() == esServiceUuid) {
        return service;
      }
    }
    return null;
  }

  Future<void> refresh() async {
    if (mounted) {
      setState(() {
        scanForDevices();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _connectInfo = Provider.of<ConnectInfo>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(widget.title),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: RefreshIndicator(
            //  Start scanning for Bluetooth LE devices
            onRefresh: () => refresh(),
            //  List of Bluetooth LE devices
            child: _buildListViewOfDevices()));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<BluetoothService>('_services', _services));
  }
}
