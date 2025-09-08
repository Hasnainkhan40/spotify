import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendUserMessageEvent extends ChatEvent {
  final String text;
  SendUserMessageEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class ClearChatEvent extends ChatEvent {}
