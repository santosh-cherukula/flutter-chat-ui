enum MessageStatus { sent, delivered, read }

class Message {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;
  final MessageStatus status;
  final String? replyToId;
  final String? reaction; // emoji or null

  Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.status = MessageStatus.sent,
    this.replyToId,
    this.reaction,
  });

  Message copyWith({
    String? id,
    String? text,
    bool? isMe,
    DateTime? time,
    MessageStatus? status,
    String? replyToId,
    String? reaction, // set to null to clear
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      reaction: reaction, // explicit: allow null to clear
    );
  }
}

/// Temporary sample data per contact
class MessageSamples {
  static List<Message> forContact(String name) {
    final now = DateTime.now();
    if (name == 'Alice') {
      return [
        Message(id: 'a1', text: 'Hey!', isMe: false, time: now.subtract(const Duration(minutes: 40))),
        Message(id: 'a2', text: 'Hi, how are you?', isMe: true, time: now.subtract(const Duration(minutes: 39)), status: MessageStatus.read),
        Message(id: 'a3', text: 'All good, you?', isMe: false, time: now.subtract(const Duration(minutes: 38))),
        Message(id: 'a4', text: 'Busy coding Flutter UI 😄', isMe: true, time: now.subtract(const Duration(minutes: 37)), status: MessageStatus.read),
      ];
    }
    if (name == 'Bob') {
      return [
        Message(id: 'b1', text: 'Let\'s meet today.', isMe: false, time: now.subtract(const Duration(hours: 1))),
        Message(id: 'b2', text: 'Sure, after 5?', isMe: true, time: now.subtract(const Duration(hours: 1, minutes: 1)), status: MessageStatus.delivered),
      ];
    }
    return [
      Message(id: 'c1', text: 'Check this out!', isMe: false, time: now.subtract(const Duration(days: 1))),
      Message(id: 'c2', text: 'Nice! 🔥', isMe: true, time: now.subtract(const Duration(days: 1, minutes: 1)), status: MessageStatus.sent),
    ];
  }
}
