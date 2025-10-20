import 'dart:convert';
import 'dart:developer';

// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:infobip_huawei_mobile_messaging/infobip_huawei_mobile_messaging.dart';
import 'package:infobip_huawei_mobile_messaging_example/inbox_page.dart';
// import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await requestNotifPermissionIfNeeded();

  final sdk = InfobipHuaweiMobileMessaging.instance;

  // Listen before initialize so you don’t miss the first token
  sdk.onToken.listen((t) => log('HMS token: $t'));
  sdk.onMessage.listen((m) => log('MESSAGE: $m'));
  sdk.onNotificationTap.listen((m) {
    log('TAP: $m');
    final payload = m['customPayload'] as String?;
    final uri = _extractDeeplink(payload); // parse JSON string safely
    if (uri != null) {
      log('Open deeplink: $uri');
      // TODO: Route to your screen:
      // Navigator.of(globalNavigatorKey.currentContext!).pushNamed(
      //   uri.path,
      //   arguments: uri.queryParameters,
      // );
    }
  });

  try {
    final ok = await sdk.initialize();
    if (!ok) {
      await _toast(
        'Init failed: check agconnect-services.json and strings.xml',
      );
    }

    final info = await InfobipHuaweiMobileMessaging.instance.diagnose();
    final hmsOk = (info['hmsStatus'] == 0);
    final hasAgc = info['appIdPresent'] == true;

    if (!hmsOk) {
      await _toast(
        'HMS Core not available. Use a Huawei device/emulator with AppGallery.',
      );
    }
    if (!hasAgc) {
      await _toast('Missing agconnect-services.json / app_id in strings.xml.');
    }
  } catch (e) {
    await _toast('Init error: agconnect-services.json or strings.xml missing');
  }
  runApp(const App());
}

// Future<void> requestNotifPermissionIfNeeded() async {
//   if (Platform.isAndroid) {
//     final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
//     if (sdkInt >= 33) {
//       await Permission.notification.request();
//     }
//   }
// }

Future<void> _toast(String msg) async {
  try {
    await Fluttertoast.showToast(msg: msg);
  } catch (_) {
    // Fallback if toast plugin isn't available on some platform
    // ignore: use_build_context_synchronously
  }
}

Uri? _extractDeeplink(String? customPayload) {
  if (customPayload == null || customPayload.isEmpty) return null;

  try {
    final map = json.decode(customPayload);
    // Infobip campaign builder typically uses one of these keys
    final link = map['deeplink'] ?? map['deep_link'] ?? map['url'];
    if (link is String && link.isNotEmpty) {
      final uri = Uri.tryParse(link);
      if (uri != null && (uri.scheme.isNotEmpty || uri.host.isNotEmpty)) {
        return uri;
      }
    }
  } catch (e, s) {
    log('Deeplink parse failed: $e\n$s');
  }
  return null;
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Infobip Huawei Example')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final ok = await InfobipHuaweiMobileMessaging.instance
                      .setUserIdentity(
                        externalUserId: 'user-123',
                        attributes: {'loyal': true},
                      );
                  await _toast(ok ? 'Identity set' : 'Failed to set identity');
                },
                child: const Text('Set identity'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await InfobipHuaweiMobileMessaging.instance.trackEvent(
                    'opened_example',
                    payload: {'ts': DateTime.now().toIso8601String()},
                  );
                },
                child: const Text('Track event'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final payload = await InfobipHuaweiMobileMessaging.instance
                        .syncInbox(
                          externalUserId: 'user-123',
                          // accessToken: '<JWT here>' // for production; leave null for sandbox
                        );
                    final inbox = await InfobipHuaweiMobileMessaging.instance
                        .getInbox(externalUserId: 'user-123');
                    log('INBOX: $inbox');
                    await _toast(
                      'Inbox synced: total=${payload['countTotal']}, unread=${payload['countUnread']}',
                    );
                  } catch (e) {
                    await _toast('Inbox error: $e');
                  }
                },
                child: const Text('Sync Inbox'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final ok = await InfobipHuaweiMobileMessaging.instance
                      .enableInAppMessages(true);
                  await _toast(
                    ok
                        ? 'In‑App enabled'
                        : 'In‑App not supported in this build',
                  );
                },
                child: const Text('Enable In-App'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const InboxPage()));
                },
                child: const Text('Open Inbox'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
