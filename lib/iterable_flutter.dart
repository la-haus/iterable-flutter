import 'dart:async';

import 'package:flutter/services.dart';

typedef void OpenedNotificationHandler(Map openedResult);

class IterableFlutter {
  static const MethodChannel _channel = const MethodChannel('iterable_flutter');

  // event handlers
  static OpenedNotificationHandler? _onOpenedNotification;

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
    _channel.setMethodCallHandler(nativeMethodCallHandler);
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

  static Future<void> signOut() async {
    await _channel.invokeMethod('signOut');
  }

  static void setNotificationOpenedHandler(OpenedNotificationHandler handler) {
    _onOpenedNotification = handler;
  }

  static Future<dynamic> nativeMethodCallHandler(MethodCall methodCall) async {

    switch (methodCall.method) {
      case "openedNotificationHandler":
        _onOpenedNotification?.call(methodCall.arguments);
        return "This data from flutter.....";
      default:
        return "Nothing";
    }
  }
}
