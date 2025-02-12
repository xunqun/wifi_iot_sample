import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_iot_tester/screen/connect_viewmodel.dart';
import 'package:wifi_iot_tester/screen/screen_transition.dart';
import 'package:wifi_iot_tester/utils/preferences.dart';

class ScreenConnect extends StatefulWidget {
  const ScreenConnect({super.key});

  @override
  State<ScreenConnect> createState() => _ScreenConnectState();
}

class _ScreenConnectState extends State<ScreenConnect> {
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool connecting = false;
  NetworkSecurity security = NetworkSecurity.WPA;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 1), () {
      String ssid = Preferences.get().ssid;
      String password = Preferences.get().password;
      setState(() {
        ssidController.text = ssid;
        passwordController.text = password;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Wifi IoT Tester',
                style: TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 60),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: ssidController,
                        decoration: InputDecoration(hintText: 'SSID'),
                      ),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(hintText: 'Password'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: DropdownMenu(
                            initialSelection: security,
                            dropdownMenuEntries: [
                              DropdownMenuEntry(label: 'WPA', value: NetworkSecurity.WPA),
                              DropdownMenuEntry(label: 'WEP', value: NetworkSecurity.WEP),
                              DropdownMenuEntry(label: 'NONE', value: NetworkSecurity.NONE),
                            ],
                            onSelected: (value) {
                              setState(() {
                                security = value as NetworkSecurity;
                              });
                            }),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () {
                            connect();
                          },
                          child: Text('Connect'))
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (connecting) CircularProgressIndicator(),
              if (connecting) Text('Connecting...')
            ],
          ),
        ),
      ),
    ));
  }

  void connect() async {
    var ssid = ssidController.text.trim();
    var password = passwordController.text;

    // Save to preferences
    Preferences.get().ssid = ssid;
    Preferences.get().password = password;

    setState(() {
      connecting = true;
    });

    bool success = await ConnectViewModel.get().connectWifi(ssid, password, security);

    if (success) {
      Fluttertoast.showToast(msg: 'Connected');
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenTransaction()));
    } else {
      Fluttertoast.showToast(msg: 'Failed');
    }
    setState(() {
      connecting = false;
    });
  }
}
