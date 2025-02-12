import 'package:fluttertoast/fluttertoast.dart';
import 'package:wifi_iot/wifi_iot.dart';

class ConnectViewModel{
  static ConnectViewModel _instance = ConnectViewModel._();
  static ConnectViewModel get() => _instance;
  ConnectViewModel._();

  Future<bool> connectWifi(String ssid, String password, NetworkSecurity security) async {

    var success = await WiFiForIoTPlugin.connect(
      ssid,
      password: password,
      joinOnce: false,
      withInternet: false,
      security: security,
      timeoutInSeconds: 10,
    ).onError((error, stackTrace) {
      print('Error: $error');
      Fluttertoast.showToast(msg: error.toString());
      return false;
    });
    WiFiForIoTPlugin.forceWifiUsage(true);
    return success;
  }

  disconnectWifi() async {
    WiFiForIoTPlugin.forceWifiUsage(false);
    await WiFiForIoTPlugin.disconnect();
  }
}