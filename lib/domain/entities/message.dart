enum Sender { user, bot }

class Message {
  final String id;
  final String text;
  final Sender sender;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}
