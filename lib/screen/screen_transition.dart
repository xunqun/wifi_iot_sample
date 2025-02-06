import 'package:flutter/material.dart';
import 'package:wifi_iot_tester/screen/connect_viewmodel.dart';
import 'package:wifi_iot_tester/screen/screen_client.dart';
import 'package:wifi_iot_tester/screen/screen_server.dart';

class ScreenTransaction extends StatefulWidget {
  const ScreenTransaction({super.key});

  @override
  State<ScreenTransaction> createState() => _ScreenTransactionState();
}

class _ScreenTransactionState extends State<ScreenTransaction> {
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController();

  @override
  void initState() {
    ipController.text = '192.168.4.1';
    portController.text = '8360';
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenServer()));
                }, child: Text("I'm Server")),
                SizedBox(height: 16),
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenClient()));
                }, child: Text("I'm Client")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    ConnectViewModel.get().disconnectWifi();
    super.dispose();
  }
}
