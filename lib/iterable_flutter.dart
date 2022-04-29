import 'dart:async';
import 'dart:convert';

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

  static Future<void> track({
    required String event,
    Map<String, dynamic>? dataFields = null,
  }) async {
    await _channel.invokeMethod('track', {
      "event": event,
      "data_fields": dataFields,
    });
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

  static Future<void> updateUser({required Map<String, dynamic> params}) async {
    await _channel.invokeMethod(
      'updateUser',
      {
        'params': params,
      },
    );
  }

  // ignore: use_setters_to_change_properties
  static void setNotificationOpenedHandler(OpenedNotificationHandler handler) {
    _onOpenedNotification = handler;
  }

  static Future<dynamic> nativeMethodCallHandler(MethodCall methodCall) async {
    final arguments = methodCall.arguments as Map<dynamic, dynamic>;
    final argumentsCleaned = sanitizeArguments(arguments);

    switch (methodCall.method) {
      case "openedNotificationHandler":
        _onOpenedNotification?.call(argumentsCleaned);
        return "This data from native.....";
      default:
        return "Nothing";
    }
  }

  static Map<String, dynamic> sanitizeArguments(
      Map<dynamic, dynamic> arguments) {
    final result = arguments;

    final data = result['additionalData'];
    data.forEach((key, value) {
      if (value is String) {
        if (value[0] == '{' && value[value.length - 1] == '}') {
          data[key] = _stringJsonToMap(value);
        }
      }
    });
    result['additionalData'] = data;

    return Map<String, dynamic>.from(result);
  }

  static Map<dynamic, dynamic> _stringJsonToMap(String stringJson) {
    final stringClean = stringJson.replaceAll('&quot;', '"');

    return jsonDecode(stringClean) as Map<dynamic, dynamic>;
  }
}
