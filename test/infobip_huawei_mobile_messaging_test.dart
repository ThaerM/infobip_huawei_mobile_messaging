import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_huawei_mobile_messaging/infobip_huawei_mobile_messaging.dart';

void main() {
  test('plugin exposes singleton instance', () {
    final instance = InfobipHuaweiMobileMessaging.instance;
    expect(instance, isNotNull);
  });

  test('streams are accessible', () {
    final api = InfobipHuaweiMobileMessaging.instance;
    expect(() => api.onToken, returnsNormally);
    expect(() => api.onMessage, returnsNormally);
    expect(() => api.onNotificationTap, returnsNormally);
  });
}
