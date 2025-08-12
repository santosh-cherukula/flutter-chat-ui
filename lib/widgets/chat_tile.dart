import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback? onTap;

  const ChatTile({super.key, required this.chat, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      leading: _AvatarWithStatus(
        imageUrl: chat.avatarUrl,
        isOnline: chat.isOnline,
        fallbackText: chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            chat.time,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: cs.onSurfaceVariant),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chat.muted)
            Icon(Icons.volume_off, size: 16, color: cs.onSurface.withOpacity(0.7)),
          if (chat.unreadCount > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: cs.primary.withOpacity(0.35),
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class _AvatarWithStatus extends StatelessWidget {
  final String imageUrl;
  final bool isOnline;
  final String fallbackText;

  const _AvatarWithStatus({
    required this.imageUrl,
    required this.isOnline,
    required this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final avatar = CircleAvatar(
      radius: 24,
      backgroundColor: cs.surface,
      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      child: imageUrl.isEmpty
          ? Text(fallbackText, style: const TextStyle(fontWeight: FontWeight.bold))
          : null,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient ring
        Container(
          padding: const EdgeInsets.all(2.2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [cs.primary, cs.primary.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: avatar,
        ),
        // Online dot
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: Colors.black, // small border ring; looks better on light/dark
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? Colors.greenAccent : cs.outlineVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
