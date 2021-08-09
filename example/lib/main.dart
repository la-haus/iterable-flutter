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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(),
      ),
    );
  }
}
