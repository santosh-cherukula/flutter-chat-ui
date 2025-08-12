import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../widgets/chat_tile.dart';
import '../models/chat_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late List<ChatModel> _chats;

  @override
  void initState() {
    super.initState();
    _chats = List<ChatModel>.from(ChatModel.sampleChats);
  }

  void _markRead(int index) {
    setState(() {
      _chats[index] = _chats[index].copyWith(unreadCount: 0);
    });
  }

  void _toggleMute(int index) {
    final c = _chats[index];
    setState(() {
      _chats[index] = c.copyWith(muted: !c.muted);
    });
  }

  void _delete(int index) {
    setState(() {
      _chats.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.search)),
          Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.more_vert)),
        ],
      ),
      body: ListView.separated(
        itemCount: _chats.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return Slidable(
            key: ValueKey('${chat.name}-$index'),
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.5,
              children: [
                SlidableAction(
                  onPressed: (_) => _markRead(index),
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  icon: Icons.mark_email_read,
                  label: 'Read',
                ),
                SlidableAction(
                  onPressed: (_) => _toggleMute(index),
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  icon: chat.muted ? Icons.volume_up : Icons.volume_off,
                  label: chat.muted ? 'Unmute' : 'Mute',
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) => _delete(index),
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: ChatTile(
              chat: chat,
              onTap: () {
                _markRead(index); // clear badge on open
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(contactName: chat.name),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.message),
        label: const Text('New chat'),
      ),
    );
  }
}
