import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/chat_model.dart';
import '../widgets/glass_card.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  
  void _markRead(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marked as read')),
    );
  }

  void _toggleMute(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Muted / Unmuted')),
    );
  }

  void _delete(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chats = ChatModel.sampleChats;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) {
          final c = chats[i];
          return Slidable(
            key: ValueKey(c.name),
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.45,
              children: [
                SlidableAction(
                  onPressed: (ctx) => _markRead(ctx, i),
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  icon: Icons.mark_email_read,
                  label: 'Read',
                ),
                SlidableAction(
                  onPressed: (ctx) => _toggleMute(ctx, i),
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  icon: Icons.volume_off,
                  label: 'Mute',
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (ctx) => _delete(ctx, i),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: GlassCard(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(c.avatarUrl),
                  child: c.avatarUrl.isEmpty ? Text(c.name[0]) : null,
                ),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(c.time, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    if (c.unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(c.unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatScreen(contactName: c.name)),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('New chat'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}