import 'dart:async';

import 'package:infobip_huawei_mobile_messaging/infobip_huawei_mobile_messaging.dart'
    as hms;

class Configuration {
  final String applicationCode;
  final bool fullFeaturedInAppsEnabled;
  final bool inAppChatEnabled;
  final AndroidSettings? androidSettings;
  final IOSSettings? iosSettings;
  Configuration({
    required this.applicationCode,
    this.fullFeaturedInAppsEnabled = true,
    this.inAppChatEnabled = true,
    this.androidSettings,
    this.iosSettings,
  });
}

class AndroidSettings {
  final String? notificationIcon;
  final bool multipleNotifications;
  final String? notificationAccentColor;
  final FirebaseOptions? firebaseOptions;
  AndroidSettings({
    this.notificationIcon,
    this.multipleNotifications = true,
    this.notificationAccentColor,
    this.firebaseOptions,
  });
}

class FirebaseOptions {
  final String apiKey;
  final String applicationId;
  final String projectId;
  FirebaseOptions({
    required this.apiKey,
    required this.applicationId,
    required this.projectId,
  });
}

class IOSSettings {
  final List<String> notificationTypes;
  final bool forceCleanup;
  final bool logging;
  IOSSettings({
    this.notificationTypes = const ["alert", "badge", "sound"],
    this.forceCleanup = false,
    this.logging = false,
  });
}

enum LibraryEvent {
  tokenReceived,
  messageReceived,
  notificationTapped,
  userUpdated,
  personalized,
  installationUpdated,
  depersonalized,
  actionTapped,
  registrationUpdated,
}

class Message {
  final String messageId;
  final String? title;
  final String? body;
  final String? deeplink;
  final int? receivedTimestamp;
  final bool? seen;
  final Map<String, dynamic>? customPayload;

  Message({
    required this.messageId,
    this.title,
    this.body,
    this.deeplink,
    this.receivedTimestamp,
    this.seen,
    this.customPayload,
  });

  factory Message.fromMap(Map<String, dynamic> m) => Message(
        messageId: (m['messageId'] ?? '') as String,
        title: m['title'] as String?,
        body: m['body'] as String?,
        deeplink: m['deeplink'] as String?,
        receivedTimestamp: (m['receivedTimestamp'] as num?)?.toInt(),
        seen: m['seen'] as bool?,
        customPayload: (m['customPayload'] is Map)
            ? Map<String, dynamic>.from(m['customPayload'])
            : (m['customPayload'] != null
                ? {'raw': m['customPayload'].toString()}
                : null),
      );
}

class Installation {
  Map<String, dynamic>? customAttributes;
}

enum Gender { Male, Female, Other }

class UserData {
  final String? firstName;
  final String? lastName;
  final List<String>? emails;
  final List<String>? phones;
  final Gender? gender;
  final Map<String, dynamic>? customAttributes;
  final String? externalUserId;
  UserData({
    this.firstName,
    this.lastName,
    this.emails,
    this.phones,
    this.gender,
    this.customAttributes,
    this.externalUserId,
  });
}

class UserIdentity {
  final String? externalUserId;
  final List<String>? emails;
  final List<String>? phones;
  UserIdentity({this.externalUserId, this.emails, this.phones});
}

class PersonalizeContext {
  final bool forceDepersonalize;
  final UserIdentity userIdentity;
  PersonalizeContext({
    required this.forceDepersonalize,
    required this.userIdentity,
  });
}

class FilterOptions {
  final DateTime? fromDateTime;
  final DateTime? toDateTime;
  final String? topic;
  final List<String>? topics;
  final int? limit;
  FilterOptions({
    this.fromDateTime,
    this.toDateTime,
    this.topic,
    this.topics,
    this.limit,
  });
}

class Inbox {
  final int? countTotal;
  final int? countUnread;
  final int? countTotalFiltered;
  final int? countUnreadFiltered;
  final List<Message>? messages;
  Inbox({
    this.countTotal,
    this.countUnread,
    this.countTotalFiltered,
    this.countUnreadFiltered,
    this.messages,
  });
}

class InfobipMobilemessaging {
  static final _tokenCtrl = StreamController<String>.broadcast();
  static final _msgCtrl = StreamController<Message>.broadcast();
  static final _tapCtrl = StreamController<Message>.broadcast();

  static bool _wired = false;

  static Future<bool> init(Configuration cfg) async {
    final ok = await hms.InfobipHuaweiMobileMessaging.instance.initialize();
    if (!_wired) {
      _wireHmsStreams();
      _wired = true;
    }
    return ok;
  }

  static void _wireHmsStreams() {
    hms.InfobipHuaweiMobileMessaging.instance.onToken.listen((t) {
      if (t != null) _tokenCtrl.add(t);
    });
    hms.InfobipHuaweiMobileMessaging.instance.onMessage.listen((m) {
      _msgCtrl.add(Message.fromMap(m));
    });
    hms.InfobipHuaweiMobileMessaging.instance.onNotificationTap.listen((m) {
      _tapCtrl.add(Message.fromMap(m));
    });
  }

  static void on(LibraryEvent evt, Function handler) {
    switch (evt) {
      case LibraryEvent.tokenReceived:
        _tokenCtrl.stream.listen((t) => handler(t));
        break;
      case LibraryEvent.messageReceived:
        _msgCtrl.stream.listen((m) => handler(m));
        break;
      case LibraryEvent.notificationTapped:
      case LibraryEvent.actionTapped:
        _tapCtrl.stream.listen((m) => handler(m));
        break;
      default:
        break;
    }
  }

  static Future<void> submitEventImmediately(Map<String, dynamic> event) async {
    final name = (event['name'] ?? 'event').toString();
    final payload = (event['payload'] is Map)
        ? Map<String, dynamic>.from(event['payload'])
        : null;
    await hms.InfobipHuaweiMobileMessaging.instance
        .trackEvent(name, payload: payload);
  }

  static Future<void> setTags(List<String> tags) async {
    await hms.InfobipHuaweiMobileMessaging.instance.setTags(tags);
  }

  static Future<void> setUserIdentityCompat(UserIdentity identity,
      {Map<String, dynamic>? attributes}) async {
    await hms.InfobipHuaweiMobileMessaging.instance.setUserIdentity(
      externalUserId: identity.externalUserId ?? '',
      attributes: attributes,
    );
  }

  static Future<void> setLanguage(String locale) async {}
  static Future<void> resetMessageCounter() async {}
  static Future<void> showChat(
      {bool shouldBePresentedModallyIOS = true}) async {}

  static Future<void> depersonalize() async {}

  static Future<Installation> getInstallation() async => Installation();
  static Future<void> saveInstallation(Installation i) async {}

  static Future<UserData> fetchUser() async => UserData();

  static Future<void> personalize(PersonalizeContext ctx) async {
    await hms.InfobipHuaweiMobileMessaging.instance.setUserIdentity(
      externalUserId: ctx.userIdentity.externalUserId ?? '',
      attributes: {},
    );
  }

  static Future<void> saveUser(UserData user) async {
    await hms.InfobipHuaweiMobileMessaging.instance.setUserIdentity(
      externalUserId: user.externalUserId ?? '',
      attributes: user.customAttributes,
    );
  }

  static Future<void> setInboxMessagesSeen(
      String externalUserId, List<String> messageIds) async {
    await hms.InfobipHuaweiMobileMessaging.instance
        .markInboxSeen(externalUserId: externalUserId, messageIds: messageIds);
  }

  static Future<Inbox> fetchInboxMessages(
    String? jwt,
    String externalUserId,
    FilterOptions filter,
  ) async {
    final map = await hms.InfobipHuaweiMobileMessaging.instance.syncInbox(
      externalUserId: externalUserId,
      accessToken: jwt,
      from: filter.fromDateTime,
      to: filter.toDateTime,
      topic: filter.topic,
      topics: filter.topics,
      limit: filter.limit,
    );
    final msgs = (map['messages'] as List? ?? const [])
        .map((e) => Message.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return Inbox(
      countTotal: (map['countTotal'] as num?)?.toInt(),
      countUnread: (map['countUnread'] as num?)?.toInt(),
      countTotalFiltered: (map['countTotalFiltered'] as num?)?.toInt(),
      countUnreadFiltered: (map['countUnreadFiltered'] as num?)?.toInt(),
      messages: msgs,
    );
  }

  static Future<void> registerForAndroidRemoteNotifications() async {}
}
