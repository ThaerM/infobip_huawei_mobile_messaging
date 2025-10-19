import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infobip_huawei_mobile_messaging/infobip_huawei_mobile_messaging.dart';

import 'inbox_message_model.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final _mm = InfobipHuaweiMobileMessaging.instance;
  List<InboxMessage> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadInbox();
  }

  Future<void> _loadInbox() async {
    setState(() => _loading = true);
    try {
      await _mm.syncInbox();
      final raw = await _mm.getInbox();
      setState(() {
        _messages = raw.map(InboxMessage.fromMap).toList();
      });
    } catch (e) {
      log('Inbox error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _markSeen(String id) async {
    await _mm.markInboxSeen(id);
    _loadInbox();
  }

  Future<void> _delete(String id) async {
    await _mm.deleteInboxMessage(id);
    _loadInbox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInbox,
              child: ListView.separated(
                itemCount: _messages.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final m = _messages[i];
                  return ListTile(
                    title: Text(m.title ?? '(no title)'),
                    subtitle: Text(m.body ?? ''),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () => _markSeen(m.messageId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(m.messageId),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
