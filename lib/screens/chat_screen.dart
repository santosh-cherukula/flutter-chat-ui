import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String contactName;
  const ChatScreen({super.key, required this.contactName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<Message> _messages;
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  String? _replyToId;
  bool _typing = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _messages = MessageSamples.forContact(widget.contactName);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  // helpers
  String _fmtTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String? _replyPreviewText(String? replyToId) {
    if (replyToId == null) return null;
    final target = _messages.cast<Message?>().firstWhere((x) => x?.id == replyToId, orElse: () => null);
    return target?.text;
  }

  // actions
  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: text,
          isMe: true,
          time: DateTime.now(),
          status: MessageStatus.sent,
          replyToId: _replyToId,
        ),
      );
      _replyToId = null;
    });

    _controller.clear();
    _autoScroll();

    // simulate delivery -> read
    Future.delayed(const Duration(milliseconds: 600), () => _updateLastStatus(MessageStatus.delivered));
    Future.delayed(const Duration(seconds: 2), () => _updateLastStatus(MessageStatus.read));

    _simulateTypingAndReply();
  }

  void _simulateTypingAndReply() {
    setState(() => _typing = true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _typing = false);
      _messages.add(
        Message(
          id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
          text: 'Got it!',
          isMe: false,
          time: DateTime.now(),
        ),
      );
      _autoScroll();
    });
  }

  void _updateLastStatus(MessageStatus s) {
    if (_messages.isEmpty) return;
    final last = _messages.last;
    if (!last.isMe) return;
    setState(() => _messages[_messages.length - 1] = last.copyWith(status: s));
  }

  void _onLongPressMessage(Message m) async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (_) => const _ReactionBar(), // returns emoji or ':info:'
    );

    if (selection == null) return;

    if (selection == ':info:') {
      _showMessageInfo(m);
      return;
    }

    // Toggle reaction (undo if same)
    final idx = _messages.indexWhere((x) => x.id == m.id);
    if (idx != -1) {
      final current = _messages[idx].reaction;
      final next = (current == selection) ? null : selection;
      setState(() {
        _messages[idx] = _messages[idx].copyWith(reaction: next);
      });
    }
  }

  void _replyTo(Message m) => setState(() => _replyToId = m.id);

  void _showAttachmentSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (ctx) {
        final items = [
          (_IconLabel(Icons.photo_camera_outlined, 'Camera'), () {}),
          (_IconLabel(Icons.photo_outlined, 'Gallery'), () {}),
          (_IconLabel(Icons.insert_drive_file_outlined, 'File'), () {}),
          (_IconLabel(Icons.place_outlined, 'Location'), () {}),
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Wrap(
            runSpacing: 16,
            alignment: WrapAlignment.spaceAround,
            children: items.map((entry) {
              final tile = entry.$1; final onTap = entry.$2;
              return InkWell(
                onTap: () { Navigator.pop(ctx); onTap(); },
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 140,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(tile.icon, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(tile.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showMessageInfo(Message m) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (ctx) {
        String fmt(DateTime t) {
          final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
          final m2 = t.minute.toString().padLeft(2, '0');
          final ampm = t.hour >= 12 ? 'PM' : 'AM';
          return '$h:$m2 $ampm';
        }

        final sentAt = m.time;
        final deliveredAt = m.isMe ? m.time.add(const Duration(seconds: 1)) : null;
        final readAt = m.isMe && m.status == MessageStatus.read
            ? m.time.add(const Duration(seconds: 2))
            : null;

        Widget row(IconData icon, String title, String value) => ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: Text(value, style: Theme.of(ctx).textTheme.bodyMedium),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              row(Icons.send, 'Sent', fmt(sentAt)),
              if (deliveredAt != null) row(Icons.done_all, 'Delivered', fmt(deliveredAt)),
              if (readAt != null) row(Icons.visibility, 'Read', fmt(readAt)),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactName),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.call_outlined)),
          Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.videocam_outlined)),
          Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (context, i) {
                if (_typing && i == _messages.length) {
                  return const _TypingIndicator();
                }
                final m = _messages[i];
                final replyPreview = _replyPreviewText(m.replyToId);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (replyPreview != null) _ReplyPreviewChip(text: replyPreview),
                    MessageBubble(
                      text: m.text,
                      time: _fmtTime(m.time),
                      isMe: m.isMe,
                      isRead: m.status == MessageStatus.read,
                      reaction: m.reaction,
                      onLongPress: () => _onLongPressMessage(m),
                      onDoubleTap: () => _replyTo(m),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_replyToId != null)
            _ReplyBar(
              text: _replyPreviewText(_replyToId)!,
              onCancel: () => setState(() => _replyToId = null),
            ),
          const Divider(height: 1),
          _Composer(
            controller: _controller,
            onSend: _send,
            onAttach: _showAttachmentSheet,
          ),
        ],
      ),
    );
  }
}

// bottom widgets

class _ReactionBar extends StatelessWidget {
  const _ReactionBar();

  static const _reactions = ['👍', '❤️', '😄', '😮', '😢', '👏'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom + MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomInset),
        child: Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _reactions
                      .map((e) => InkWell(
                            onTap: () => Navigator.pop(context, e),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(e, style: const TextStyle(fontSize: 22)),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context, ':info:'),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Info'),
                      style: TextButton.styleFrom(foregroundColor: cs.onSurface.withOpacity(0.9)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconLabel {
  final IconData icon;
  final String label;
  const _IconLabel(this.icon, this.label);
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  const _Composer({required this.controller, required this.onSend, required this.onAttach});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
        child: Row(
          children: [
            IconButton(onPressed: onAttach, icon: const Icon(Icons.attach_file)),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cs.outlineVariant.withOpacity(.3)),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: onSend,
              backgroundColor: cs.primary,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyBar extends StatelessWidget {
  final String text;
  final VoidCallback onCancel;
  const _ReplyBar({required this.text, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.04),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis)),
          IconButton(onPressed: onCancel, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}

class _ReplyPreviewChip extends StatelessWidget {
  final String text;
  const _ReplyPreviewChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const _Dots(),
      ),
    );
  }
}

class _Dots extends StatefulWidget {
  const _Dots();

  @override
  State<_Dots> createState() => _DotsState();
}

class _DotsState extends State<_Dots> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        double v(int i) => (1 + (0.6 * (i == 0 ? _c.value : i == 1 ? (_c.value + 0.33) % 1 : (_c.value + 0.66) % 1)));
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6 * v(i),
              height: 6 * v(i),
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }
}
