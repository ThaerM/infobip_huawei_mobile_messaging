import 'dart:async';

import 'package:flutter/services.dart';

import 'infobip_huawei_mobile_messaging_platform_interface.dart';

/// Method-channel implementation of [InfobipHuaweiMobileMessagingPlatform].
///
/// This bridges all Dart calls to the native Kotlin/Swift plugins through
/// the standard Flutter method/event channels.
class MethodChannelInfobipHuaweiMobileMessaging
    extends InfobipHuaweiMobileMessagingPlatform {
  static const MethodChannel _m =
      MethodChannel('infobip_huawei_mobile_messaging/methods');

  static const EventChannel _tokenEvents =
      EventChannel('infobip_huawei_mobile_messaging/events/token');
  static const EventChannel _messageEvents =
      EventChannel('infobip_huawei_mobile_messaging/events/message');
  static const EventChannel _tapEvents =
      EventChannel('infobip_huawei_mobile_messaging/events/notification_tap');

  // --- helpers ---------------------------------------------------------------
  T? _as<T>(dynamic v) => v is T ? v : null;
  Map<String, dynamic> _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  /// Returns a JSON-safe (encodable) deep copy of [value].
  /// Filters out values the platform channel can't serialize.
  dynamic _jsonSafe(dynamic value) {
    if (value == null) return null;
    if (value is num || value is String || value is bool) return value;
    if (value is List) return value.map(_jsonSafe).toList();
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _jsonSafe(v)));
    }
    // Fallback: stringify unknown objects
    return value.toString();
  }

  Stream<String?>? _onToken;
  Stream<Map<String, dynamic>>? _onMessage;
  Stream<Map<String, dynamic>>? _onTap;

  @override
  Future<bool> initialize() async {
    final res = await _m.invokeMethod<bool>('initialize');
    return res ?? false;
  }

  @override
  Future<String?> getToken() => _m.invokeMethod<String>('getToken');

  @override
  Stream<String?> get onToken => _onToken ??=
      _tokenEvents.receiveBroadcastStream().map((e) => _as<String>(e));

  @override
  Stream<Map<String, dynamic>> get onMessage =>
      _onMessage ??= _messageEvents.receiveBroadcastStream().map(_asMap);

  @override
  Stream<Map<String, dynamic>> get onNotificationTap =>
      _onTap ??= _tapEvents.receiveBroadcastStream().map(_asMap);

  @override
  Future<bool> setUserIdentity({
    required String externalUserId,
    Map<String, dynamic>? attributes,
  }) async {
    final args = <String, dynamic>{
      'externalUserId': externalUserId,
      if (attributes != null) 'attributes': _jsonSafe(attributes),
    };
    final res = await _m.invokeMethod<bool>('setUserIdentity', args);
    return res ?? false;
  }

  @override
  Future<bool> setTags(List<String> tags) async {
    final res = await _m.invokeMethod<bool>('setTags', {'tags': tags});
    return res ?? false;
  }

  @override
  Future<bool> trackEvent(String name, {Map<String, dynamic>? payload}) async {
    final args = {
      'name': name,
      if (payload != null) 'payload': _jsonSafe(payload)
    };
    final res = await _m.invokeMethod<bool>('trackEvent', args);
    return res ?? false;
  }

  @override
  Future<bool> enableInAppMessages(bool enabled) async {
    final res = await _m.invokeMethod<bool>(
      'enableInAppMessages',
      {'enabled': enabled},
    );
    return res ?? false;
  }

  @override
  Future<Map<String, dynamic>> syncInbox({
    required String externalUserId,
    String? accessToken,
    DateTime? from,
    DateTime? to,
    String? topic,
    List<String>? topics,
    int? limit,
  }) async {
    final args = <String, dynamic>{
      'externalUserId': externalUserId,
      if (accessToken != null) 'accessToken': accessToken,
      if (from != null) 'fromDateTime': from.millisecondsSinceEpoch,
      if (to != null) 'toDateTime': to.millisecondsSinceEpoch,
      if (topic != null) 'topic': topic,
      if (topics != null) 'topics': topics,
      if (limit != null) 'limit': limit,
    };
    final res = await _m.invokeMethod<Map>('syncInbox', args);
    return Map<String, dynamic>.from(res ?? const {});
  }

  @override
  Future<Map<String, dynamic>> getInbox({
    required String externalUserId,
    String? accessToken,
    DateTime? from,
    DateTime? to,
    String? topic,
    List<String>? topics,
    int? limit,
  }) async {
    final args = <String, dynamic>{
      'externalUserId': externalUserId,
      if (accessToken != null) 'accessToken': accessToken,
      if (from != null) 'fromDateTime': from.millisecondsSinceEpoch,
      if (to != null) 'toDateTime': to.millisecondsSinceEpoch,
      if (topic != null) 'topic': topic,
      if (topics != null) 'topics': topics,
      if (limit != null) 'limit': limit,
    };
    final res = await _m.invokeMethod<Map>('getInbox', args);
    return Map<String, dynamic>.from(res ?? const {});
  }

  @override
  Future<List<String>> markInboxSeen({
    required String externalUserId,
    required List<String> messageIds,
  }) async {
    final res = await _m.invokeMethod<List<dynamic>>('markInboxSeen', {
      'externalUserId': externalUserId,
      'messageIds': messageIds,
    });
    return res?.cast<String>() ?? const [];
  }

  @override
  Future<void> deleteInboxMessage(String messageId) =>
      _m.invokeMethod('deleteInboxMessage', {'messageId': messageId});

  @override
  Future<Map<String, dynamic>> diagnose() async {
    final res = await _m.invokeMethod<Map>('diagnose');
    return Map<String, dynamic>.from(res ?? const {});
  }
}
