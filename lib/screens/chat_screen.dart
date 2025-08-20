import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
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
  // in _ChatScreenState
  bool _userTyping = false;
  bool _showSearch = false;
  bool _showEmoji = false;

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

  String _fmtTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  String? _replyPreviewText(String? replyToId) {
    if (replyToId == null) return null;
    final target = _messages.cast<Message?>().firstWhere((x) => x?.id == replyToId, orElse: () => null);
    return target?.text;
  }

  // 🔽 Inside _ChatScreenState
  Widget _buildSwipeMessage(Message m) {
  return Dismissible(
    key: ValueKey(m.id),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 16),
      color: const Color(0xFF0096C7).withOpacity(0.1),
      child: const Icon(Icons.reply, color: Color(0xFF0096C7)),
    ),
    onDismissed: (_) => _replyTo(m),
    child: _OceanMessageBubble(
      message: m,
      onLongPress: () => _onLongPressMessage(m),
      onDoubleTap: () => _replyTo(m),
    ),
  );
  }

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
      _userTyping = false; // <-- Add this line
    });

    _controller.clear();
    _autoScroll();

    Future.delayed(const Duration(milliseconds: 600), () => _updateStatus(MessageStatus.delivered));
    Future.delayed(const Duration(seconds: 2), () => _updateStatus(MessageStatus.read));

    _simulateTypingAndReply();
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

  void _updateStatus(MessageStatus s) {
    if (_messages.isEmpty || !_messages.last.isMe) return;
    setState(() => _messages[_messages.length - 1] = _messages.last.copyWith(status: s));
  }

  final _searchController = TextEditingController();
  List<Message> _filtered = [];
  bool _searching = false;

  void _search(String query) {
  setState(() {
    _searching = query.isNotEmpty;
    _filtered = _messages
        .where((m) => m.text.toLowerCase().contains(query.toLowerCase()))
        .toList();
  });
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

  void _onLongPressMessage(Message m) async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (_) => const _ReactionBar(),
    );

    if (selection == null) return;
    if (selection == ':info:') {
      _showMessageInfo(m);
      return;
    }

    final idx = _messages.indexWhere((x) => x.id == m.id);
    if (idx != -1) {
      final current = _messages[idx].reaction;
      final next = (current == selection) ? null : selection;
      setState(() => _messages[idx] = _messages[idx].copyWith(reaction: next));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000814), Color(0xFF001E3C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.contactName),
                Text(
                     _typing
                          ? 'Online'
                          : 'Last seen ${_fmtTime(_messages.last.time)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
              actions: [
                const SizedBox(width: 8),
                const Icon(Icons.call_outlined, color: Colors.white),
                const SizedBox(width: 8),
                const Icon(Icons.videocam_outlined, color: Colors.white),
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 0) {
                      setState(() => _showSearch = !_showSearch);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 0, child: Text('Search')),
                  ],
                ),
              ],
            ),
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (text) {
                    setState(() {}); // triggers filter
                  },
                  decoration: InputDecoration(
                    hintText: 'Search messages…',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF00D9FF)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            Expanded(
              child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _searchController.text.isEmpty
                  ? _messages.length + (_typing ? 1 : 0) + (_userTyping ? 1 : 0)
                  : _messages.where((m) => m.text.toLowerCase().contains(_searchController.text.toLowerCase())).length,
              itemBuilder: (context, i) {
                // Check if this index is for a typing indicator
                if (_searchController.text.isEmpty) {
                  if (i >= _messages.length) {
                    // Determine which typing indicator we're showing
                    if (_typing && _userTyping) {
                      // Both typing - determine which one is at this index
                      bool isUserTyping = i == _messages.length; // First extra spot is user typing
                      return _AnimatedTypingBubble(isMe: isUserTyping);
                    } else {
                      // Only one is typing - figure out which one
                      return _AnimatedTypingBubble(isMe: !_typing); // If not other person typing, must be user
                    }
                  }
                  
                  // Regular message
                  final m = _messages[i];
                  final replyPreview = _replyPreviewText(m.replyToId);
                  
                  return Dismissible(
                    key: ValueKey(m.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async { _replyTo(m); return false; },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (replyPreview != null) _ReplyPreviewChip(text: replyPreview),
                        _OceanMessageBubble(
                          message: m,
                          onLongPress: () => _onLongPressMessage(m),
                          onDoubleTap: () => _replyTo(m),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Search results
                  final filteredMessages = _messages.where((m) => 
                    m.text.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                  final m = filteredMessages[i];
                  // Rest of your code for search results...
                }
                return null;
              },
            ),
            ),
            if (_replyToId != null)
              _ReplyBar(
                text: _replyPreviewText(_replyToId)!,
                onCancel: () => setState(() => _replyToId = null),
              ),
            //const Divider(height: 1),
           Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
            child: Row(
              children: [
          _VoiceRecorderButton(
            onStart: () => setState(() => _typing = true),
            onEnd: () {
              setState(() {
                _typing = false;
                _messages.add(
                  Message(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    text: '🎤 Voice message',
                    isMe: true,
                    time: DateTime.now(),
                    status: MessageStatus.sent,
                  ),
                );
              });
              _autoScroll();
            },
          ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showAttachmentSheet,
                  icon: const Icon(Icons.attach_file, color: Color(0xFF00D9FF)),
                ),
                IconButton(
                onPressed: () => setState(() => _showEmoji = !_showEmoji),
                icon: const Icon(Icons.emoji_emotions, color: Color(0xFF00D9FF)),
              ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF001E3C).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: (text) {
                        setState(() => _userTyping = text.isNotEmpty);
                        },
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send, color: Color(0xFF00D9FF)),
                ),
              ],
            ),
          ),
          if (_showEmoji)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              textEditingController: _controller,
              config: Config(
                // columns: 8,
                // iconColorSelected: const Color(0xFF00D9FF),
                // backspaceColor: const Color(0xFF0096C7),
              ),
        ),
          ),
      ],
    ),
        ),
      );
  }
}

class _VoiceRecorderButton extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onEnd;

  const _VoiceRecorderButton({required this.onStart, required this.onEnd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => onStart(),
      onLongPressEnd: (_) => onEnd(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF0096C7),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.mic, color: Colors.white),
      ),
    );
  }
}

// 🌊 Ocean components (re-wired to keep all features)
class _OceanMessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  const _OceanMessageBubble({
    required this.message,
    this.onLongPress,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMe
                ? const Color(0xFF0096C7)
                : const Color(0xFF003F5C),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message.text,
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
              if (message.reaction != null) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(message.reaction!,
                      style: const TextStyle(fontSize: 14, color: Colors.white)),
                ),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_fmtTime(message.time),
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.status == MessageStatus.read
                          ? Icons.done_all
                          : Icons.check,
                      size: 12,
                      color: Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}


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
                const SizedBox(height: 6),
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

class _TypingBubble extends StatelessWidget {
  final bool isMe;
  const _TypingBubble({required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF0096C7)
              : const Color(0xFF003F5C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          '⋯',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
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

class _AnimatedTypingBubble extends StatefulWidget {
  final bool isMe;
  const _AnimatedTypingBubble({required this.isMe});

  @override
  __AnimatedTypingBubbleState createState() => __AnimatedTypingBubbleState();
}

class __AnimatedTypingBubbleState extends State<_AnimatedTypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isMe
              ? const Color(0xFF0096C7)
              : const Color(0xFF003F5C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.4 + 0.6 * (i == 0
                          ? _controller.value
                          : i == 1
                              ? (_controller.value + 0.33) % 1
                              : (_controller.value + 0.66) % 1),
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}