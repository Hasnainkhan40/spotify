import 'package:dartz/dartz.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';

abstract class SongsRepository {
  Future<Either> getNewsSongs();
  Future<Either> getPlayList();
  Future<Either> addOrRemoveFavoriteSongs(String songId);
  Future<bool> isFavoriteSong(String songId);
  Future<Either> getUserFavoriteSongs();
  Future<Either<String, void>> storeSong(SongEntity song);
}
