import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wifi_iot_tester/screen/connect_viewmodel.dart';
import 'package:wifi_iot_tester/utils/preferences.dart';

class ScreenClient extends StatefulWidget {
  const ScreenClient({super.key});

  @override
  State<ScreenClient> createState() => _ScreenClientState();
}

class _ScreenClientState extends State<ScreenClient> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isClientConnected = false;
  String _receivedMessage = '';
  Socket? _socket;

  StreamSubscription? _socketSub;

  @override
  void initState() {
    _ipController.text = Preferences.get().ip;
    _portController.text = Preferences.get().port;
    super.initState();
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    _ipController.dispose();
    _portController.dispose();
    WakelockPlus.disable();
    stopClient();
    ConnectViewModel.get().disconnectWifi();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Align(alignment: Alignment.topRight, child: IconButton(onPressed: () {
                ConnectViewModel.get().disconnectWifi();
                //back to ScreenConnect
                Navigator.popUntil(context, (route) => route.isFirst);
              }, icon: Icon(Icons.close))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'I\'m Client',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _isClientConnected ? 'Connected' : 'Disconnected',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _isClientConnected ? Colors.green : Colors.red),
                  ),
                  TextField(
                      controller: _ipController,
                      decoration: const InputDecoration(
                        labelText: 'IP Address',
                        hintText: 'IP Address',
                      )),
                  TextField(
                      controller: _portController,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        hintText: 'Port',
                      )),
                  ElevatedButton(
                    onPressed: () {
                      if (_isClientConnected) {
                        stopClient();
                      } else {
                        startClient();
                      }
                    },
                    child: Text(_isClientConnected ? '中斷連線' : '連線到Server'),
                  ),

                  // message received log
                  const SizedBox(
                    height: 48,
                  ),
                  if (_isClientConnected)
                    Expanded(
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            _receivedMessage,
                            style: const TextStyle(fontSize: 12),
                          )),
                    ),
                  if (_isClientConnected)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _contentController,
                              decoration: const InputDecoration(
                            labelText: 'Message',
                            hintText: 'Message',
                          )),
                        ),
                        IconButton(
                          onPressed: () {
                            var content = _contentController.text;
                            _socket?.write(content);
                            _contentController.clear();
                          },
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    )
                ],
              )
            ],
          ),
        ),
      )),
    );
  }

  void stopClient() {
    _socket?.destroy();
    if(mounted) {
      setState(() {
        _isClientConnected = false;
      });
    }
  }

  void startClient() {
    var ip = _ipController.text;
    var port = int.tryParse(_portController.text);
    Preferences.get().ip = ip;
    Preferences.get().port = port.toString();
    Socket.connect('192.168.4.1', 80, timeout: Duration(seconds: 10)).then((socket) {
      _socket = socket;
      if (_socket == null) {
        return;
      }
      setState(() {
        _isClientConnected = true;
        WakelockPlus.enable();
      });
      _socketSub = socket.listen((event) {
        setState(() {
          _receivedMessage += String.fromCharCodes(event).trim() + '\n';
        });
      })
        ..onDone(() {
          setState(() {
            _isClientConnected = false;
          });
          socket.destroy();
        })
        ..onError((error, stackTrace) {
          print('Error: $error');
        })
        ..onData((data) {
          setState(() {
            _receivedMessage = String.fromCharCodes(data).trim();
          });

          print('Data: $data');
        });
    }).onError((error, stackTrace) {
      print('Error: $error');
      Fluttertoast.showToast(msg: error.toString());
      setState(() {
        _isClientConnected = false;
      });
    });
  }
}
