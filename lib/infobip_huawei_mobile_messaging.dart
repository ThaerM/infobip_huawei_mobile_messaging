import 'dart:async';

import 'infobip_huawei_mobile_messaging_platform_interface.dart';

/// Public API facade for the Infobip Huawei Mobile Messaging plugin.
///
/// Apps should import only this file. All calls are delegated to the
/// current platform implementation via
/// [InfobipHuaweiMobileMessagingPlatform.instance].
class InfobipHuaweiMobileMessaging {
  InfobipHuaweiMobileMessaging._();
  static final InfobipHuaweiMobileMessaging instance =
      InfobipHuaweiMobileMessaging._();

  // ---------------------------
  // Lifecycle / core
  // ---------------------------
  Future<bool> initialize() =>
      InfobipHuaweiMobileMessagingPlatform.instance.initialize();

  Future<String?> getToken() =>
      InfobipHuaweiMobileMessagingPlatform.instance.getToken();

  // ---------------------------
  // Event streams
  // ---------------------------
  Stream<String?> get onToken =>
      InfobipHuaweiMobileMessagingPlatform.instance.onToken;

  Stream<Map<String, dynamic>> get onMessage =>
      InfobipHuaweiMobileMessagingPlatform.instance.onMessage;

  Stream<Map<String, dynamic>> get onNotificationTap =>
      InfobipHuaweiMobileMessagingPlatform.instance.onNotificationTap;

  // ---------------------------
  // User / tags / events / in-app
  // ---------------------------
  Future<bool> setUserIdentity({
    required String externalUserId,
    Map<String, dynamic>? attributes,
  }) =>
      InfobipHuaweiMobileMessagingPlatform.instance.setUserIdentity(
        externalUserId: externalUserId,
        attributes: attributes,
      );

  Future<bool> setTags(List<String> tags) =>
      InfobipHuaweiMobileMessagingPlatform.instance.setTags(tags);

  Future<bool> trackEvent(String name, {Map<String, dynamic>? payload}) =>
      InfobipHuaweiMobileMessagingPlatform.instance
          .trackEvent(name, payload: payload);

  Future<bool> enableInAppMessages(bool enabled) =>
      InfobipHuaweiMobileMessagingPlatform.instance
          .enableInAppMessages(enabled);

  // ---------------------------
  // Inbox
  // ---------------------------
  Future<Map<String, dynamic>> syncInbox({
    required String externalUserId,
    String? accessToken,
    DateTime? from,
    DateTime? to,
    String? topic,
    List<String>? topics,
    int? limit,
  }) =>
      InfobipHuaweiMobileMessagingPlatform.instance.syncInbox(
        externalUserId: externalUserId,
        accessToken: accessToken,
        from: from,
        to: to,
        topic: topic,
        topics: topics,
        limit: limit,
      );

  Future<Map<String, dynamic>> getInbox({
    required String externalUserId,
    String? accessToken,
    DateTime? from,
    DateTime? to,
    String? topic,
    List<String>? topics,
    int? limit,
  }) =>
      InfobipHuaweiMobileMessagingPlatform.instance.getInbox(
        externalUserId: externalUserId,
        accessToken: accessToken,
        from: from,
        to: to,
        topic: topic,
        topics: topics,
        limit: limit,
      );

  Future<List<String>> markInboxSeen({
    required String externalUserId,
    required List<String> messageIds,
  }) =>
      InfobipHuaweiMobileMessagingPlatform.instance.markInboxSeen(
        externalUserId: externalUserId,
        messageIds: messageIds,
      );

  Future<void> deleteInboxMessage(String messageId) =>
      InfobipHuaweiMobileMessagingPlatform.instance
          .deleteInboxMessage(messageId);

  Future<Map<String, dynamic>> diagnose() =>
      InfobipHuaweiMobileMessagingPlatform.instance.diagnose();
}
