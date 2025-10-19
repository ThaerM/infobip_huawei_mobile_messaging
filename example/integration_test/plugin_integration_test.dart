// Basic integration smoke test for the plugin API.
//
// This test is intentionally device-agnostic. It verifies that the Dart API
// can be loaded and its streams can be accessed without requiring Huawei
// AppGallery / HMS push configuration. Do NOT call initialize() here since
// it depends on native HMS setup.
//
// If you add real device tests later, gate them behind flags and keep this
// smoke test fast and hermetic.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_huawei_mobile_messaging/infobip_huawei_mobile_messaging.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'plugin API is loadable without HMS setup',
    (WidgetTester tester) async {
      // Access singleton to ensure the library loads.
      final api = InfobipHuaweiMobileMessaging.instance;
      expect(api, isNotNull);

      // Accessing stream getters must not throw synchronously.
      expect(() => api.onToken, returnsNormally);
      expect(() => api.onMessage, returnsNormally);
      expect(() => api.onNotificationTap, returnsNormally);

      // IMPORTANT:
      // Do not invoke methods that require native side (e.g., initialize()) here.
      // Those should live in separate, opt-in tests on real Huawei devices.
    },
    // integration_test is not supported on web and some CI targets; skip there.
    skip: kIsWeb,
  );
}
