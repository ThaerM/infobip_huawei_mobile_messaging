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
  final String _externalUserId = 'user-123';
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
      final _ = await _mm.syncInbox(
        externalUserId: _externalUserId,
        // accessToken: '<JWT for production>'
      );
      final fetched = await _mm.getInbox(externalUserId: _externalUserId);
      final list = List<Map<String, dynamic>>.from(
        (fetched['messages'] as List?) ?? const <Map<String, dynamic>>[],
      );
      setState(() {
        _messages = list.map(InboxMessage.fromMap).toList();
      });
    } catch (e) {
      log('Inbox error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Inbox error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markSeen(String id) async {
    try {
      await _mm.markInboxSeen(
        externalUserId: _externalUserId,
        messageIds: [id],
      );
      await _loadInbox();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Mark seen failed: $e')));
      }
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _mm.deleteInboxMessage(id);
    } catch (_) {
      // ignore – native returns an error by design on Huawei
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delete is not supported on Huawei client SDK'),
        ),
      );
    }
    await _loadInbox();
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
