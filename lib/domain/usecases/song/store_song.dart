import 'package:dartz/dartz.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';
import 'package:spotify/domain/repository/song/song.dart';

class StoreSongUseCase {
  final SongsRepository repository;
  StoreSongUseCase(this.repository);

  Future<Either<String, void>> call(SongEntity song) {
    return repository.storeSong(song);
  }
}
