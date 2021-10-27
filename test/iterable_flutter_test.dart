import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iterable_flutter/iterable_flutter.dart';

void main() {
  final calledMethod = <MethodCall>[];

  const MethodChannel channel = MethodChannel('iterable_flutter');
  const String apiKey = 'apiKey';
  const String pushIntegrationName = 'pushIntegrationName';
  const String activeLogDebug = 'activeLogDebug';
  const String email = 'my@email.com';
  const String userId = '11111';
  const String event = 'my_event';

  const contentBody = "Test body push";
  const keyBody = "body";

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      calledMethod.add(methodCall);

      switch (methodCall.method) {
        case 'init':
          return null;
        case 'setEmail':
          return null;
        case 'setUserId':
          return null;
        case 'track':
          return null;
        case 'registerForPush':
          return null;
        case 'signOut':
          return null;
        case 'checkRecentNotification':
          return null;
        case 'updateUser':
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    calledMethod.clear();
    channel.setMockMethodCallHandler(null);
  });

  test('initialize', () async {
    await IterableFlutter.initialize(
      apiKey: apiKey,
      pushIntegrationName: pushIntegrationName,
    );
    expect(calledMethod, <Matcher>[
      isMethodCall(
        'initialize',
        arguments: {
          apiKey: apiKey,
          pushIntegrationName: pushIntegrationName,
          activeLogDebug: false
        },
      ),
    ]);
  });

  test('setEmail', () async {
    await IterableFlutter.setEmail(email);
    expect(calledMethod, <Matcher>[
      isMethodCall('setEmail', arguments: email),
    ]);
  });

  test('setUserId', () async {
    await IterableFlutter.setUserId(userId);
    expect(calledMethod, <Matcher>[
      isMethodCall('setUserId', arguments: userId),
    ]);
  });

  test('track', () async {
    await IterableFlutter.track(event);
    expect(calledMethod, <Matcher>[
      isMethodCall('track', arguments: event),
    ]);
  });

  test('registerForPush', () async {
    await IterableFlutter.registerForPush();
    expect(calledMethod, <Matcher>[
      isMethodCall('registerForPush', arguments: null),
    ]);
  });

  test('signOut', () async {
    await IterableFlutter.signOut();
    expect(calledMethod, <Matcher>[
      isMethodCall('signOut', arguments: null),
    ]);
  });

  test('checkRecentNotification', () async {
    IterableFlutter.setNotificationOpenedHandler((openedResultMap) {});
    expect(calledMethod, <Matcher>[
      isMethodCall('checkRecentNotification', arguments: null),
    ]);
  });

  test("openedNotificationHandler", () async {
    IterableFlutter.initialize(
      apiKey: apiKey,
      pushIntegrationName: pushIntegrationName,
    );

    dynamic pushData;

    IterableFlutter.setNotificationOpenedHandler((openedResultMap) {
      pushData = openedResultMap;
    });

    await ServicesBinding.instance?.defaultBinaryMessenger
        .handlePlatformMessage(
            'iterable_flutter',
            const StandardMethodCodec().encodeMethodCall(
              const MethodCall(
                'openedNotificationHandler',
                {keyBody: contentBody},
              ),
            ),
            (ByteData? data) {});

    expect(contentBody, pushData[keyBody]);
  });

  test('updateUser', () async {
    await IterableFlutter.updateUser(params);
    expect(calledMethod, <Matcher>[
      isMethodCall('updateUser', arguments: params),
    ]);
  });
}
