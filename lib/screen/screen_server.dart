import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ScreenServer extends StatefulWidget {
  const ScreenServer({super.key});

  @override
  State<ScreenServer> createState() => _ScreenServerState();
}

class _ScreenServerState extends State<ScreenServer> {
  TextEditingController _ipController = TextEditingController();
  TextEditingController _portController = TextEditingController();
  bool _isServerCreated = false;
  bool _isClientConnected = false;
  String _receivedMessage = '';
  ServerSocket? _serverSocket;
  Socket? _socket;
  String _ipList = '';

  @override
  void initState() {
    var address = '192.168.4.1';
    _ipController.text = address;
    _portController.text = '8360';
    super.initState();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    stopServer();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                const Text('Server', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                Text(_isServerCreated ? 'Started': 'Stopped', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _isServerCreated ? Colors.green : Colors.red),),
                if(_isClientConnected) Text('Client connected', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),),
                TextField(
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: 'IP Address',
                    hintText: 'IP Address',)
                ),
                TextField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    hintText: 'Port',)
                ),
                Text(_ipList),
                ElevatedButton(
                  onPressed: () {
                    if(_isServerCreated) {
                      stopServer();
                    } else {
                      startServer();
                    }
                  },
                  child: Text(_isServerCreated ? 'Stop Server' : 'Start Server'),
                ),

                // message received log
                const SizedBox(height: 48,),
                if(_isServerCreated) Expanded(
                  child: Align(alignment: Alignment.topLeft, child: Text(_receivedMessage, style: const TextStyle(fontSize: 12),)),
                ),
                if(_isServerCreated) Row(
                  children: [
                    const Expanded(
                      child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Message',
                            hintText: 'Message',)
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.send),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  void startServer() async{
    int port = int.tryParse(_portController.text.toString()) ?? 8360;

    // var internetAddr = InternetAddress.tryParse(ip);
    // debugPrint('Starting server at ${ip!.address}:$port');
    ServerSocket.bind(InternetAddress.anyIPv4, port).then((serverSocket) async{
      _serverSocket = serverSocket;
      String? ip = await NetworkInfo().getWifiIP();
      _ipList = '';
      NetworkInterface.list(type: InternetAddressType.IPv4).then((value) {
        value.forEach((element) {
          debugPrint('name: ${element.name}, address: ${element.addresses}');
          _ipList += '${element.name}: ${element.addresses}\n';
        });
        setState(() {});
      });

      setState(() {
        _isServerCreated = true;
        WakelockPlus.enable();
      });

      serverSocket.listen((socket) {
        _socket = socket;
        socket.listen((data) {
          setState(() {
            _receivedMessage = String.fromCharCodes(data).trim();
          });
        });
        setState(() {
          _receivedMessage = 'Client connected';
          _isClientConnected = true;
        });

      })..onDone(() {
        stopServer();
      })..onError((error, stackTrace) {
        Fluttertoast.showToast(msg: error.toString());
      });

    }).onError((error, stackTrace) {
      Fluttertoast.showToast(msg: error.toString());
      stopServer();
    });


  }

  void stopServer() {
    _serverSocket?.close();
    _socket?.close();
    setState(() {
      _isServerCreated = false;
    });
  }
}
