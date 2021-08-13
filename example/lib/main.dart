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
    final apiKey = FlutterConfig.get('ITERABLE_API_KEY');
    final pushIntegrationName =
        FlutterConfig.get('ITERABLE_PUSH_INTEGRATION_NAME');

    return await IterableFlutter.initialize(
      apiKey: apiKey,
      pushIntegrationName: pushIntegrationName,
    );
  }

  /// Don't set an email and user ID in the same session.
  /// Doing so causes the SDK to treat them as different users.
  Future<void> setEmail(String email) async {
    await IterableFlutter.setEmail(email);
  }

  /// Don't set an email and user ID in the same session.
  /// Doing so causes the SDK to treat them as different users.
  Future<void> setUserId(String userId) async {
    await IterableFlutter.setUserId(userId);
  }

  Future<void> track(String event) async {
    await IterableFlutter.track(event);
  }

  /// Call it to register device for current user if calling setEmail or
  /// setUserId after the app has already launched
  /// (for example, when a new user logs in)
  Future<void> registerForPush() async {
    await IterableFlutter.registerForPush();
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
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (value) {
                    setEmail(value);
                    track('init_register_push_set_email');
                  },
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Email:',
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
