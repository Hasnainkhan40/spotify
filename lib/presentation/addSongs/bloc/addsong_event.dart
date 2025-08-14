import 'package:equatable/equatable.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';

abstract class StoreSongEvent extends Equatable {
  const StoreSongEvent();

  @override
  List<Object?> get props => [];
}

class StoreSongRequested extends StoreSongEvent {
  final SongEntity song;

  const StoreSongRequested(this.song);

  @override
  List<Object?> get props => [song];
}
