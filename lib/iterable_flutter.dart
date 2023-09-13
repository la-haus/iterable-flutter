import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iterable_flutter/iterable_in_app_message_preview.dart';

typedef IterableActionHandler = void Function(
    Map<String, dynamic> openedResult);

// ignore: avoid_classes_with_only_static_members
class IterableFlutter {
  static const MethodChannel _channel = MethodChannel('iterable_flutter');

  static IterableActionHandler? _actionHandler;

  const IterableFlutter._();
  static IterableFlutter? _singleton;
  static IterableFlutter get instance {
    _singleton ??= IterableFlutter._();
    return _singleton!;
  }

  Future<void> initialize({
    required String apiKey,
    required String pushIntegrationName,
    bool activeLogDebug = false,
    List<String> allowedProtocols = const ['https'],
  }) async {
    await _channel.invokeMethod(
      'initialize',
      {
        'apiKey': apiKey,
        'pushIntegrationName': pushIntegrationName,
        'activeLogDebug': activeLogDebug,
        'allowedProtocols': allowedProtocols,
      },
    );
    _channel.setMethodCallHandler(_nativeMethodCallHandler);
  }

  Future<void> setEmail(String email) async {
    await _channel.invokeMethod('setEmail', email);
  }

  Future<void> setUserId(String userId) async {
    await _channel.invokeMethod('setUserId', userId);
  }

  Future<void> track(String event) async {
    await _channel.invokeMethod('track', event);
  }

  Future<void> registerForPush() async {
    await _channel.invokeMethod('registerForPush');
  }

  Future<void> signOut() async {
    await _channel.invokeMethod('signOut');
  }

  Future<void> checkRecentNotification() async {
    await _channel.invokeMethod('checkRecentNotification');
  }

  Future<void> updateUser({required Map<String, dynamic> params}) async {
    await _channel.invokeMethod(
      'updateUser',
      {
        'params': params,
      },
    );
  }

  Future<void> showMobileInbox({
    String? screenTitle,
    String? noMessagesTitle,
    String? noMessagesBody,
  }) async {
    await _channel.invokeMethod(
      'showMobileInbox',
      {
        'screenTitle': screenTitle,
        'noMessagesTitle': noMessagesTitle,
        'noMessagesBody': noMessagesBody,
      },
    );
  }

  Future<int?> getUnreadInboxMessagesCount() {
    return _channel.invokeMethod<int>('getUnreadInboxMessagesCount');
  }

  Future<List<IterableInAppMessagePreview?>?> getInboxMessages() async {
    final jsonMessages =
        await _channel.invokeMethod<List<dynamic>>('getInboxMessages');

    final messages = jsonMessages?.map((e) {
      try {
        return IterableInAppMessagePreview.fromJson(json.decode(e.toString()));
      } catch (e) {
        return null;
      }
    }).toList();

    return messages;
  }

  Future<bool> showInboxMessage({required String messageId}) async {
    final result = await _channel.invokeMethod(
      'showInboxMessage',
      {
        'messageId': messageId,
      },
    );

    return result;
  }

  Future<void> dismissPresentedInboxMessage() async {
    await _channel.invokeMethod('dismissPresentedInboxMessage');
  }

  // ignore: use_setters_to_change_properties
  void setIterableActionHandler(IterableActionHandler handler) {
    _actionHandler = handler;
  }

  Future<dynamic> _nativeMethodCallHandler(MethodCall methodCall) async {
    final arguments = methodCall.arguments as Map<dynamic, dynamic>;
    final argumentsCleaned = sanitizeArguments(arguments);

    switch (methodCall.method) {
      case "actionHandler":
        _actionHandler?.call(argumentsCleaned);
        return;
      default:
        return;
    }
  }

  @visibleForTesting
  Map<String, dynamic> sanitizeArguments(Map<dynamic, dynamic> arguments) {
    final result = arguments;

    final data = (result['itbl'] is String)
        ? _stringJsonToMap(result['itbl'])
        : result['itbl'];
    data.forEach((key, value) {
      if (value is String) {
        if (value.isNotEmpty && [0] == '{' && value[value.length - 1] == '}') {
          data[key] = _stringJsonToMap(value);
        }
      }
    });
    result['itbl'] = data;

    return Map<String, dynamic>.from(result);
  }

  Map<dynamic, dynamic> _stringJsonToMap(String stringJson) {
    final stringClean = stringJson.replaceAll('&quot;', '"');

    return jsonDecode(stringClean) as Map<dynamic, dynamic>;
  }
}
