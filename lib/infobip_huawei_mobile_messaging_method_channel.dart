import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'infobip_huawei_mobile_messaging_platform_interface.dart';

/// An implementation of [InfobipHuaweiMobileMessagingPlatform] that uses method channels.
class MethodChannelInfobipHuaweiMobileMessaging extends InfobipHuaweiMobileMessagingPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('infobip_huawei_mobile_messaging');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
