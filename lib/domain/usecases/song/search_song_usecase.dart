import 'package:dartz/dartz.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';
import 'package:spotify/domain/repository/song/song.dart';

class SearchSongUseCase {
  final SongsRepository repository;

  SearchSongUseCase(this.repository);

  Future<Either<String, List<SongEntity>>> call(String query) async {
    return await repository.searchSongs(query);
  }
}
