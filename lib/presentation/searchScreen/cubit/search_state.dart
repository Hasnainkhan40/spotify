import 'package:spotify/domain/entities/song/song_entity.dart';

abstract class SearchSongState {}

class SearchSongInitial extends SearchSongState {}

class SearchSongLoading extends SearchSongState {}

class SearchSongLoaded extends SearchSongState {
  final List<SongEntity> songs;
  SearchSongLoaded(this.songs);
}

class SearchSongError extends SearchSongState {
  final String message;
  SearchSongError(this.message);
}
