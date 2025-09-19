import '../../domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required String id,
    required String text,
    required Sender sender,
    required DateTime timestamp,
  }) : super(id: id, text: text, sender: sender, timestamp: timestamp);

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      text: json['text'],
      sender: json['sender'] == 'user' ? Sender.user : Sender.bot,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender == Sender.user ? 'user' : 'bot',
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
