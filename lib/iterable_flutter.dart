import 'dart:async';

import 'package:flutter/services.dart';

class IterableFlutter {
  static const MethodChannel _channel = const MethodChannel('iterable_flutter');

  static Future<void> initialize({
    required String apiKey,
    required String pushIntegrationName,
  }) async {
    await _channel.invokeMethod(
      'initialize',
      {
        'apiKey': apiKey,
        'pushIntegrationName': pushIntegrationName,
      },
    );
  }

  static Future<void> setEmail(String email) async {
    await _channel.invokeMethod('setEmail', email);
  }

  static Future<void> setUserId(String userId) async {
    await _channel.invokeMethod('setUserId', userId);
  }

  static Future<void> track(String event) async {
    await _channel.invokeMethod('track', event);
  }

  static Future<void> registerForPush() async {
    await _channel.invokeMethod('registerForPush');
  }
}
