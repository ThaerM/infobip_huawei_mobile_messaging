import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_huawei_mobile_messaging/infobip_huawei_mobile_messaging.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel =
      MethodChannel('infobip_huawei_mobile_messaging/methods');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == 'initialize') return true;
      if (call.method == 'setUserIdentity') return true;
      if (call.method == 'setTags') return true;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('initialize() returns true', () async {
    final api = InfobipHuaweiMobileMessaging.instance;
    final ok = await api.initialize(
      applicationCode: 'dummy',
      huaweiAppId: 'dummy',
    );
    expect(ok, isTrue);
  });

  test('setUserIdentity() completes', () async {
    final api = InfobipHuaweiMobileMessaging.instance;
    expect(
      api.setUserIdentity('test_user', attributes: {'age': 30}),
      completes,
    );
  });
}
