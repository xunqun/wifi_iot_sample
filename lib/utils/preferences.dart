import 'package:shared_preferences/shared_preferences.dart';

class Preferences{
  static final Preferences _instance = Preferences._();
  SharedPreferences? _prefs;
  Preferences._(){
    SharedPreferences.getInstance().then((value) => _prefs = value);
  }



  static Preferences get() => _instance;

  String get ssid => (_prefs?.getString('ssid')) ?? 'KOSO_GPS';
  set ssid(String value) => _prefs?.setString('ssid', value);

  String get password => (_prefs?.getString('password')) ?? '00000000';
  set password(String value) => _prefs?.setString('password', value);
}