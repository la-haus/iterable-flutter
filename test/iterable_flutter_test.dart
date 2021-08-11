import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iterable_flutter/iterable_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('iterable_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'init':
          return null;
        case 'setEmail':
          return null;
        case 'setUserId':
          return null;
        case 'track':
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('init', () async {
    await IterableFlutter.init('apiKey');
    //TODO: expect
    //expect(actual, matcher);
  });
}
