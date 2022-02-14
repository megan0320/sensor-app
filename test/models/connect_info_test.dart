import 'package:air_quality/models/connect_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("ConnectInfo ChangeNotifier tests", () {
    var connectInfo = ConnectInfo();
    var devId = "00:11:22:33:44:FF";
    test("test setting device ID", () {
      connectInfo.addListener(() {
        expect(connectInfo.deviceID, equals(devId));
      });
    });

    connectInfo.deviceID = devId;
  });
}
