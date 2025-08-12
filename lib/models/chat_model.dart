class ChatModel {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool muted;

  // now optional with defaults
  final String avatarUrl;
  final bool isOnline;

  ChatModel({
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.muted = false,
    String? avatarUrl,
    bool? isOnline,
  })  : avatarUrl = avatarUrl ?? '',
        isOnline = isOnline ?? false;

  ChatModel copyWith({
    String? name,
    String? lastMessage,
    String? time,
    int? unreadCount,
    bool? muted,
    String? avatarUrl,
    bool? isOnline,
  }) {
    return ChatModel(
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      unreadCount: unreadCount ?? this.unreadCount,
      muted: muted ?? this.muted,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  // Sample data (kept)
  static List<ChatModel> sampleChats = [
    ChatModel(
      name: "Alice",
      lastMessage: "Hey, how are you?",
      time: "10:20 AM",
      unreadCount: 3,
      avatarUrl: "https://i.pravatar.cc/150?img=1",
      isOnline: true,
    ),
    ChatModel(
      name: "Bob",
      lastMessage: "Let's meet today.",
      time: "9:15 AM",
      avatarUrl: "https://i.pravatar.cc/150?img=12",
      isOnline: false,
    ),
    ChatModel(
      name: "Charlie",
      lastMessage: "Check this out!",
      time: "Yesterday",
      unreadCount: 1,
      muted: true,
      avatarUrl: "https://i.pravatar.cc/150?img=22",
      isOnline: true,
    ),
    ChatModel(
      name: "Diana",
      lastMessage: "Sent the files.",
      time: "Mon",
      avatarUrl: "https://i.pravatar.cc/150?img=28",
      isOnline: false,
    ),
  ];
}
