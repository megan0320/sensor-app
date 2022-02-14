import 'dart:async';

import 'package:air_quality/widgets/air_quality_monitor.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger(
  filter: null,
  printer: PrettyPrinter(
    methodCount: 0,
  ),
  output: null,
);

/// A implementation of Air Quality Checker device communicated via Bluetooth, aka "Air-Master".
class BluetoothAqc extends AirQualityChecker {
  static const logTag = "AirQualityMonitor";
  static const String keyDeviceID = "device_id";
  FlutterBlue flutterBlue = FlutterBlue.instance;

  static const esServiceUuid = '0000181A-0000-1000-8000-00805F9B34FB';
  static const co2CharUuid = '5F41534B-4348-0000-0000-414D5F434F32';
  static const vocCharUuid = '00002BD3-0000-1000-8000-00805F9B34FB';
  static const temperatureCharUuid = '00002A6E-0000-1000-8000-00805F9B34FB';
  static const humidityCharUuid = '00002A6F-0000-1000-8000-00805F9B34FB';

  late BluetoothCharacteristic _co2Char;
  late BluetoothCharacteristic _vocChar;
  late BluetoothCharacteristic _temperatureChar;
  late BluetoothCharacteristic _humidityChar;

  /// Bluetooth device MAC address
  final String devID;
  bool connectState=false;
  final _stateController = StreamController<int>.broadcast();

  int _state = -1;
  Timer? _timer;

  BluetoothAqc({required this.devID}) : super();

  /// Initialize environment sensing service
  void _initEssService(BluetoothService ess) {
    var characteristics = ess.characteristics;
    for (BluetoothCharacteristic characteristic in characteristics) {
      logger.i('Found characteristic, UUID = [${characteristic.uuid}]');
      switch (characteristic.uuid.toString().toUpperCase()) {
        case co2CharUuid:
          _co2Char = characteristic;
          break;
        case vocCharUuid:
          _vocChar = characteristic;
          break;
        case temperatureCharUuid:
          _temperatureChar = characteristic;
          break;
        case humidityCharUuid:
          _humidityChar = characteristic;
          break;
        default:
          logger.w('Unexpected characteristic, UUID = ${characteristic.uuid}');
      }
    }

    _updateState(AirQualityChecker.connected);
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

  void _updateState(int state) {
    if (_state != state) {
      _state = state;
      _timer?.cancel();
      if (state == AirQualityChecker.disconnected) {
        // defer the update of a disconnected state due to FlutterBlue always reports disconnected first
        // when a connect() is invoked
        _timer = Timer(const Duration(seconds: 3), () {
          logger.v("Update(deferred) state to $_state");
          _stateController.add(_state);
          _timer = null;
        });
      } else {
        logger.v("Update state to $_state");
        _stateController.add(_state);
      }
    }
  }

  @override
  Future<bool> connect() async {
    bool connected = false;
    _updateState(AirQualityChecker.connecting);

    if (devID.isEmpty) {
      logger.w("Can not connect due to device ID not specified.");
      _updateState(AirQualityChecker.disconnected);
      return false;
    }

    List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
    BluetoothDevice? targetDevice;

    if (devices.isNotEmpty) {
      for (BluetoothDevice device in devices) {
        if (device.id.toString() == devID) {
          targetDevice = device;
          connected = true;
          break;
        }
      }
    }

    if (targetDevice == null) {
      var results = flutterBlue.scan(timeout: const Duration(seconds: 5));

      await for (final result in results) {
        logger.i("Scanned device: ${result.device.name} [${result.device.id}]");
        var id = result.device.id.toString();
        if (id.isNotEmpty && id == devID) {
          targetDevice = result.device;
          break;
        }
      }

      flutterBlue.stopScan();
    }

    if (targetDevice != null) {
      logger.i("Connect to ${targetDevice.name} [${targetDevice.id}}}]");

      // a connect is required (even the device is reported connected) to ensure
      // the underlying Bluetooth GATT components are working
      //if (!connected)
      {
        try {
          targetDevice.connect(timeout: const Duration(seconds: 10));
        } catch (e) {
          logger.w("Connect exception: $e");
        }
      }



      targetDevice.state.listen((state) async {
        switch (state) {
          case BluetoothDeviceState.connected:
            connectState=true;
            List<BluetoothService> services =
                await targetDevice!.discoverServices();
            var essService = _findEssService(services);
            if (essService != null) {
              _initEssService(essService);
              _updateState(AirQualityChecker.connected);
            } else {
              logger.e("ESS service not found!");
              _updateState(AirQualityChecker.disconnected);
            }
            break;
          case BluetoothDeviceState.disconnected:
            logger.i("Device disconnected");
            _updateState(AirQualityChecker.disconnected);

            break;
          default:
        }
      });
    } else {
      _updateState(AirQualityChecker.disconnected);
    }

    return false;
  }

  @override
  Future<bool> isConnected() async {
    List<BluetoothDevice> devices = await flutterBlue.connectedDevices;

    // TBD
    SharedPreferences pref = await SharedPreferences.getInstance();

    var dev_id = pref.getString(keyDeviceID);



    if (devices.isEmpty) {
      return false;
    }

    for (BluetoothDevice device in devices) {
      //logger.i("Connected device = ${dev_id}");
      if (device.id.toString() == dev_id) {

        try {
          await device.connect();
        } catch (e) {
          logger.e("Connect device failed, err = $e");
        }

        device.state.listen((state) {
          switch (state) {
            case BluetoothDeviceState.connected:
              logger.i("Device connected");
              _updateState(AirQualityChecker.connected);
              break;
            case BluetoothDeviceState.disconnected:

              logger.i("Device disconnected");
              _updateState(AirQualityChecker.disconnected);

              break;
            default:
          }
        });

        try {
          List<BluetoothService> services = await device.discoverServices();
          var essService = _findEssService(services);
          if (essService != null) {
            _initEssService(essService);
            return true;
          }
        } catch (e) {
          logger.e("Discover service failed, err = $e");
        }
      }
    }

    return false;
  }

  @override
  Stream<int> get state => _stateController.stream;

  Future<List<int>> _readCharacteristic(
      BluetoothCharacteristic characteristic) async {
    try {
      List<int> value = await characteristic.read();
      return value;
    } catch (e) {
      logger.e("Read characteristic[${characteristic.uuid} failed, err = $e");
    }

    return List<int>.filled(2, 0);
  }

  @override
  Future<int> readCO2() async {
    List<int> value = await _readCharacteristic(_co2Char);
    logger.v("CO2 value = $value");
    return (value[1] << 8) | value[0];
  }

  @override
  Future<int> readVoc() async {
    List<int> value = await _readCharacteristic(_vocChar);
    logger.v("VOC value = $value");
    return (value[1] << 8 | value[0]);
  }

  @override
  Future<double> readTemperature() async {
    List<int> value = await _readCharacteristic(_temperatureChar);
    logger.v("Temperature value = $value");

    int signedNumber = value[1] << 8 | value[0];
    if (value[1] & 0x80 != 0) {
      signedNumber = 0 - ((~signedNumber + 1) & 0xFFFF);
    }

    return (signedNumber) / 100;
  }

  @override
  Future<int> readHumidity() async {
    List<int> value = await _readCharacteristic(_humidityChar);

    logger.v("Humidity value = $value");
    return (value[1] << 8 | value[0]) ~/ 100;
  }


}


