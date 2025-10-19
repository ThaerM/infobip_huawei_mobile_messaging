import 'dart:async';

import 'package:flutter/services.dart';

class InfobipHuaweiMobileMessaging {
  InfobipHuaweiMobileMessaging._();
  static final instance = InfobipHuaweiMobileMessaging._();

  static const _m = MethodChannel('infobip_huawei_mobile_messaging/methods');
  static const _tokenEvents = EventChannel(
    'infobip_huawei_mobile_messaging/events/token',
  );
  static const _messageEvents = EventChannel(
    'infobip_huawei_mobile_messaging/events/message',
  );
  static const _tapEvents = EventChannel(
    'infobip_huawei_mobile_messaging/events/notification_tap',
  );

  Stream<String?>? _onToken;
  Stream<Map<String, dynamic>>? _onMessage;
  Stream<Map<String, dynamic>>? _onNotificationTap;

  Future<bool> initialize({
    required String applicationCode,
    required String huaweiAppId,
    bool enableInApp = false,
    String? applicationName,
  }) async {
    final ok = await _m.invokeMethod<bool>('initialize', {
      'applicationCode': applicationCode,
      'huaweiAppId': huaweiAppId,
      'enableInApp': enableInApp,
      'applicationName': applicationName,
    });
    return ok ?? false;
  }

  Stream<String?> get onToken =>
      _onToken ??= _tokenEvents.receiveBroadcastStream().cast<String?>();

  Stream<Map<String, dynamic>> get onMessage => _onMessage ??= _messageEvents
      .receiveBroadcastStream()
      .map((e) => Map<String, dynamic>.from(e));

  Stream<Map<String, dynamic>> get onNotificationTap =>
      _onNotificationTap ??= _tapEvents.receiveBroadcastStream().map(
        (e) => Map<String, dynamic>.from(e),
      );

  Future<String?> getToken() => _m.invokeMethod<String>('getToken');

  Future<void> setUserIdentity(
    String externalUserId, {
    Map<String, dynamic>? attributes,
  }) => _m.invokeMethod('setUserIdentity', {
    'externalUserId': externalUserId,
    'attributes': attributes,
  });
  // In-App
  Future<void> enableInAppMessages(bool enabled) =>
      _m.invokeMethod('enableInAppMessages', {'enabled': enabled});

  // Inbox
  Future<void> syncInbox() => _m.invokeMethod('syncInbox');

  Future<List<Map<String, dynamic>>> getInbox() async {
    final res = await _m.invokeMethod<List<dynamic>>('getInbox');
    return (res ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> markInboxSeen(String messageId) =>
      _m.invokeMethod('markInboxSeen', {'messageId': messageId});

  Future<void> deleteInboxMessage(String messageId) =>
      _m.invokeMethod('deleteInboxMessage', {'messageId': messageId});

  Future<void> setTags(List<String> tags) =>
      _m.invokeMethod('setTags', {'tags': tags});

  Future<void> trackEvent(String name, {Map<String, dynamic>? payload}) =>
      _m.invokeMethod('trackEvent', {'name': name, 'payload': payload});
}
