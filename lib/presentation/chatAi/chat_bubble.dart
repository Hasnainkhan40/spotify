// import 'package:flutter/material.dart';
// import '../../domain/entities/message.dart';

// class ChatBubble extends StatelessWidget {
//   final Message message;
//   const ChatBubble({super.key, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     final isUser = message.sender == Sender.user;
//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         padding: const EdgeInsets.all(12),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.7,
//         ),
//         decoration: BoxDecoration(
//           color: isUser ? Colors.blueAccent : Colors.grey[300],
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Text(
//           message.text,
//           style: TextStyle(color: isUser ? Colors.white : Colors.black87),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
import '../../domain/entities/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == Sender.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient:
              isUser
                  ? LinearGradient(
                    colors:
                        context.isDarkMode
                            ? [Color(0xff42C83C), Color(0xff42C83C)]
                            : [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : LinearGradient(
                    colors:
                        context.isDarkMode
                            ? [Colors.grey.shade200, Colors.grey.shade300]
                            : [Colors.grey.shade200, Colors.grey.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
