import 'dart:async';

import 'package:flutter/services.dart';

typedef OpenedNotificationHandler = void Function(Map openedResult);

// ignore: avoid_classes_with_only_static_members
class IterableFlutter {
  static const MethodChannel _channel = MethodChannel('iterable_flutter');

  static OpenedNotificationHandler? _onOpenedNotification;

  static Future<void> initialize({
    required String apiKey,
    required String pushIntegrationName,
    bool activeLogDebug = false,
  }) async {
    await _channel.invokeMethod(
      'initialize',
      {
        'apiKey': apiKey,
        'pushIntegrationName': pushIntegrationName,
        'activeLogDebug': activeLogDebug
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

  static Future<void> checkRecentNotification() async {
    await _channel.invokeMethod('checkRecentNotification');
  }

  // ignore: use_setters_to_change_properties
  static void setNotificationOpenedHandler(OpenedNotificationHandler handler) {
    _onOpenedNotification = handler;
    checkRecentNotification();
  }

  static Future<dynamic> nativeMethodCallHandler(MethodCall methodCall) async {
    final arguments = methodCall.arguments as Map<dynamic, dynamic>;

    switch (methodCall.method) {
      case "openedNotificationHandler":
        _onOpenedNotification?.call(arguments);
        return "This data from navitve.....";
      default:
        return "Nothing";
    }
  }
}
