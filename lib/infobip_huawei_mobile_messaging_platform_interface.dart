import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'infobip_huawei_mobile_messaging_method_channel.dart';

/// Platform interface for the Infobip Huawei Mobile Messaging plugin.
///
/// This declares the full cross‑platform surface that the method‑channel
/// implementation (and any future FFI/web implementations) must conform to.
/// Keep this file free of any MethodChannel specifics.
abstract class InfobipHuaweiMobileMessagingPlatform extends PlatformInterface {
  InfobipHuaweiMobileMessagingPlatform() : super(token: _token);

  static final Object _token = Object();

  static InfobipHuaweiMobileMessagingPlatform _instance =
      MethodChannelInfobipHuaweiMobileMessaging();

  /// The default instance of [InfobipHuaweiMobileMessagingPlatform] used by the package.
  static InfobipHuaweiMobileMessagingPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// class that extends [InfobipHuaweiMobileMessagingPlatform] when they register.
  static set instance(InfobipHuaweiMobileMessagingPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // ---------------------------
  // Lifecycle / core
  // ---------------------------

  /// Initializes the native SDK.
  ///
  /// On Android (Huawei), native side reads required config from resources
  /// and returns `true` when initialized.
  Future<bool> initialize();

  /// Returns the current push token if available (or `null`), but note the
  /// recommended way is to listen to [onToken].
  Future<String?> getToken();

  // ---------------------------
  // Event streams
  // ---------------------------

  /// Emits whenever a new push token is received.
  Stream<String?> get onToken;

  /// Emits a map for each received push message.
  ///
  /// Keys: `messageId`, `title`, `body`, `customPayload`, `sound`.
  Stream<Map<String, dynamic>> get onMessage;

  /// Emits a map when a notification is tapped.
  ///
  /// Keys: `messageId`, `title`, `body`, `customPayload`.
  Stream<Map<String, dynamic>> get onNotificationTap;

  // ---------------------------
  // User / tags / events / in-app
  // ---------------------------

  /// Sets user identity and optional attributes.
  ///
  /// On Huawei, attributes may be limited depending on SDK capabilities.
  Future<bool> setUserIdentity({
    required String externalUserId,
    Map<String, dynamic>? attributes,
  });

  /// Sets user tags.
  Future<bool> setTags(List<String> tags);

  /// Tracks a custom event with optional payload.
  Future<bool> trackEvent(String name, {Map<String, dynamic>? payload});

  /// Enables or disables in-app messages (if supported by the SDK build).
  Future<bool> enableInAppMessages(bool enabled);

  // ---------------------------
  // Inbox
  // ---------------------------

  /// Fetches inbox, with optional filters.
  ///
  /// Returns a map with: `countTotal`, `countUnread`,
  /// `countTotalFiltered`, `countUnreadFiltered`, and `messages` (list).
  Future<Map<String, dynamic>> syncInbox({
    required String externalUserId,
    String? accessToken,
    DateTime? from,
    DateTime? to,
    String? topic,
    List<String>? topics,
    int? limit,
  });

  /// Alias of [syncInbox] with the same parameters/return.
  Future<Map<String, dynamic>> getInbox({
    required String externalUserId,
    String? accessToken,
    DateTime? from,
    DateTime? to,
    String? topic,
    List<String>? topics,
    int? limit,
  });

  /// Marks the provided inbox message IDs as seen for a given user.
  ///
  /// Returns the list of IDs that were marked as seen.
  Future<List<String>> markInboxSeen({
    required String externalUserId,
    required List<String> messageIds,
  });

  /// Client-side delete is not supported on Huawei; native may return an error.
  Future<void> deleteInboxMessage(String messageId);

  Future<Map<String, dynamic>> diagnose();
}
