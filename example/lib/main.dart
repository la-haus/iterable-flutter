import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:iterable_flutter/iterable_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initIterable();
  }

  Future<void> initIterable() async {
    var apiKey = FlutterConfig.get('ITERABLE_API_KEY');
    await IterableFlutter.init(apiKey);
  }

  Future<void> setEmail(String email) async {
    await IterableFlutter.setEmail(email);
  }

  Future<void> setUserId(String userId) async {
    await IterableFlutter.setUserId(userId);
  }

  Future<void> track(String event) async {
    await IterableFlutter.track(event);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Iterable Example App'),
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 48, right: 96),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (value) {
                    setUserId(value.toString());
                    track('init_with_firebase');
                  },
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'User Id:',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
