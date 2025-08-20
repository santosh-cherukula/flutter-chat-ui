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
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000814), Color(0xFF001E3C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
      // Grid overlay
      CustomPaint(
        painter: _GridPainter(),
        size: Size.infinite,
      ),
      
      // Chat list
      ListView.separated(
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
  ],
),
floatingActionButton: Padding(
  padding: const EdgeInsets.only(bottom: 80), // Adjust based on nav bar height
  child: TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 800),
    curve: Curves.elasticOut,
    builder: (context, value, child) {
      return Transform.scale(
        scale: value,
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 8,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          label: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0096C7), Color(0xFF00BFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9D00FF).withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: Colors.white),
                const SizedBox(width: 8),
                const Text('New Chat', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    },
  ),
),
    );
  }
}
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.08)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}