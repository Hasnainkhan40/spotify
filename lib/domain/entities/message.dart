enum Sender { user, assistant, system }

class ChatMessage {
  final String id;
  final String text;
  final Sender sender;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({String? text}) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      sender: sender,
      timestamp: timestamp,
    );
  }
}
