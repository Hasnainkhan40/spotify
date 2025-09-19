import 'package:spotify/data/sources/chat_remote_datasource.dart';
import 'package:spotify/domain/entities/message.dart';
import 'package:spotify/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<Message> getReply(String prompt) async {
    return await remoteDataSource.sendMessage(prompt);
  }
}
