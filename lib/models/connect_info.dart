import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [ConnectInfo] manages the information required to establish the connection to a Air Master device
class ConnectInfo extends ChangeNotifier {
  /// Air Master device ID (Bluetooth address)
  static const keyDeviceID = "device_id";

  static SharedPreferences? _sharedPreferences;

  String get deviceID {
    return _sharedPreferences?.getString(keyDeviceID) ?? "";
    //return _sharedPreferences?.getString(keyDeviceID) ?? "00:A0:50:00:00:19";
  }

  set deviceID(String id) {
    _sharedPreferences?.setString(keyDeviceID, id);
    notifyListeners();
  }

  static Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }
}
