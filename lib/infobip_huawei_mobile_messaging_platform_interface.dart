import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'infobip_huawei_mobile_messaging_method_channel.dart';

abstract class InfobipHuaweiMobileMessagingPlatform extends PlatformInterface {
  /// Constructs a InfobipHuaweiMobileMessagingPlatform.
  InfobipHuaweiMobileMessagingPlatform() : super(token: _token);

  static final Object _token = Object();

  static InfobipHuaweiMobileMessagingPlatform _instance = MethodChannelInfobipHuaweiMobileMessaging();

  /// The default instance of [InfobipHuaweiMobileMessagingPlatform] to use.
  ///
  /// Defaults to [MethodChannelInfobipHuaweiMobileMessaging].
  static InfobipHuaweiMobileMessagingPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [InfobipHuaweiMobileMessagingPlatform] when
  /// they register themselves.
  static set instance(InfobipHuaweiMobileMessagingPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
