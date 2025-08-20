import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;
    
    return GestureDetector(
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isMe
                ? [const Color(0xFF9D00FF), const Color(0xFF00F5FF)]
                : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(5),
            bottomRight: isMe ? const Radius.circular(5) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: (isMe ? const Color(0xFF9D00FF) : Colors.white)
                  .withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  if (isMe)
                    Row(
                      children: [
                        Icon(
                          isRead ? Icons.done_all : Icons.check,
                          size: 16,
                          color: isRead 
                              ? const Color(0xFF00F5FF) 
                              : Colors.white70,
                        ),
                        if (reaction != null) ...[
                          const SizedBox(width: 8),
                          Text(reaction!, style: const TextStyle(fontSize: 14)),
                        ],
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}