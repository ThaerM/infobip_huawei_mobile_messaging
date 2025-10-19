class InboxMessage {
  final String messageId;
  final String? title;
  final String? body;
  final DateTime? received;
  final String? customPayload;
  final bool seen;

  InboxMessage({
    required this.messageId,
    this.title,
    this.body,
    this.received,
    this.customPayload,
    this.seen = false,
  });

  factory InboxMessage.fromMap(Map<String, dynamic> map) => InboxMessage(
    messageId: map['messageId'] ?? '',
    title: map['title'] as String?,
    body: map['body'] as String?,
    received: map['receivedTimestamp'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['receivedTimestamp'])
        : null,
    customPayload: map['customPayload'] as String?,
    seen: map['seen'] == true,
  );
}
