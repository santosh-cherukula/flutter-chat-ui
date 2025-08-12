import 'package:flutter/material.dart';

class MessageBubble extends StatefulWidget {
  final String text;
  final String time;
  final bool isMe;
  final bool isRead;
  final String? reaction;

  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  const MessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
    required this.isRead,
    this.reaction,
    this.onLongPress,
    this.onDoubleTap,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _scale = CurvedAnimation(parent: _pop, curve: Curves.easeOutBack);
    if (widget.reaction != null) _pop.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant MessageBubble old) {
    super.didUpdateWidget(old);
    if (old.reaction != widget.reaction && widget.reaction != null) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = widget.isMe ? cs.primaryContainer : cs.surface;
    final tx = widget.isMe ? cs.onPrimaryContainer : cs.onSurface;
    final border = widget.isMe ? null : Border.all(color: cs.outlineVariant);

    BorderRadius radius(bool tailRight) => BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft:
              tailRight ? const Radius.circular(16) : const Radius.circular(6),
          bottomRight:
              tailRight ? const Radius.circular(6) : const Radius.circular(16),
        );

    final IconData tick = widget.isRead ? Icons.done_all : Icons.check;
    final Color tickColor = widget.isRead ? cs.primary : tx.withOpacity(0.6);

    // Slimmer max width — ~72% of screen
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.72;

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: GestureDetector(
          onLongPress: widget.onLongPress,
          onDoubleTap: widget.onDoubleTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: radius(widget.isMe),
              border: border,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.text,
                    style: TextStyle(color: tx, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.time,
                      style: TextStyle(
                        color: tx.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                    if (widget.isMe) ...[
                      const SizedBox(width: 6),
                      Icon(tick, size: 16, color: tickColor),
                    ],
                  ],
                ),
                if (widget.reaction != null)
                  ScaleTransition(
                    scale: _scale,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.reaction!,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
