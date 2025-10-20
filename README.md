# Infobip Huawei Mobile Messaging

A Flutter plugin that provides a **clean, modern wrapper** around the [Infobip Mobile Messaging Huawei SDK](https://github.com/infobip/mobile-messaging-sdk-huawei).

It enables seamless integration of **Huawei Push Notifications**, **Inbox**, **In-App Messaging**, and **custom user data tracking** into your Flutter apps.

---

## 🚀 Features

- ✅ Receive and handle Huawei push notifications
- ✅ Listen for message and notification tap events
- ✅ Manage inbox messages (fetch, mark as seen)
- ✅ Track custom events
- ✅ Set user identity and tags
- ✅ Enable/disable in-app messages
- ✅ Built with clean architecture (platform interface separation)

---

## 📋 Requirements

- **Huawei AppGallery Connect** project with **Push Kit** enabled.
- **agconnect-services.json** placed in your app directory:
  ```
  android/app/agconnect-services.json
  ```
- Your app’s `strings.xml` must include:
  ```xml
  <string name="app_id">YOUR_HUAWEI_APP_ID</string>
  <string name="infobip_application_code">YOUR_INFOBIP_APP_CODE</string>
  ```
- A valid **Infobip Mobile Application Profile** with Huawei push enabled.

---

## ⚙️ Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  infobip_huawei_mobile_messaging: ^0.1.0
```

Then run:
```bash
flutter pub get
```

---

## 🧩 Initialization

```dart
import 'package:infobip_huawei_mobile_messaging/infobip_huawei_mobile_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sdk = InfobipHuaweiMobileMessaging.instance;

  final ok = await sdk.initialize();
  if (ok) {
    print('Infobip Huawei Messaging initialized successfully');
  }

  runApp(const MyApp());
}
```

---

## 🔔 Listening to Events

```dart
sdk.onToken.listen((token) => print('Token: $token'));
sdk.onMessage.listen((message) => print('Message: $message'));
sdk.onNotificationTap.listen((tap) => print('Notification tapped: $tap'));
```

---

## 👤 Managing User Identity

```dart
await sdk.setUserIdentity(
  externalUserId: 'user_12345',
  attributes: {'tier': 'gold', 'active': true},
);

await sdk.setTags(['flutter', 'huawei', 'infobip']);
```

---

## 📥 Inbox Management

```dart
final inbox = await sdk.syncInbox(externalUserId: 'user_12345');
print('Inbox count: ${inbox['countTotal']}');

await sdk.markInboxSeen(
  externalUserId: 'user_12345',
  messageIds: ['msg_001'],
);
```

> 📝 Note: Deleting inbox messages is not supported on the Huawei client SDK. Use Infobip’s REST API for deletion.

---

## 🧠 Diagnostics

If you’re running on a non-Huawei device or emulator, the plugin can’t reach HMS services.
You can check the environment:

```dart
final info = await sdk.diagnose();
print('Diagnostics: $info');
```

Example result:
```json
{
  "hmsStatus": 1,
  "hasHuaweiID": false,
  "appIdPresent": true,
  "infobipCodePresent": true
}
```

---

## 🧱 Clean Architecture

This plugin is built using Flutter’s platform interface pattern:
- `infobip_huawei_mobile_messaging.dart`: public API (facade)
- `infobip_huawei_mobile_messaging_platform_interface.dart`: defines the abstract platform interface
- `infobip_huawei_mobile_messaging_method_channel.dart`: MethodChannel implementation

This design makes the plugin **testable, maintainable, and extendable**.

---

## 🧰 Example Project

See the included `example/` app for working integration and UI examples.

Run it with:
```bash
cd example
flutter run
```

---

## 📄 License

MIT License © 2025 Infobip Flutter Integration Community
Thaer Mousa - Software Engineer
