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
      switch (call.method) {
        case 'initialize':
        case 'setUserIdentity':
        case 'setTags':
        case 'enableInAppMessages':
        case 'syncInbox':
        case 'getInbox':
        case 'markInboxSeen':
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('initialize() returns true', () async {
    final api = InfobipHuaweiMobileMessaging.instance;
    final ok = await api.initialize();
    expect(ok, isTrue);
  });

  test('setUserIdentity() completes', () async {
    final api = InfobipHuaweiMobileMessaging.instance;
    expect(
      api.setUserIdentity(
        externalUserId: 'test_user',
        attributes: {'age': 30},
      ),
      completes,
    );
  });

  test('enableInAppMessages() returns true', () async {
    final api = InfobipHuaweiMobileMessaging.instance;
    final ok = await api.enableInAppMessages(true);
    expect(ok, isTrue);
  });

  test('setTags() returns true', () async {
    final api = InfobipHuaweiMobileMessaging.instance;
    final ok = await api.setTags(['vip', 'tester']);
    expect(ok, isTrue);
  });
}
