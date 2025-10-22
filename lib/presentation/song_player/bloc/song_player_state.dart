import 'package:just_audio/just_audio.dart';

abstract class SongPlayerState {}

class SongPlayerLoading extends SongPlayerState {}

class SongPlayerLoaded extends SongPlayerState {
  final String songUrl;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final LoopMode loopMode;
  final bool isShuffleEnabled;
  final bool isFavorite;

  SongPlayerLoaded({
    required this.songUrl,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.loopMode,
    required this.isShuffleEnabled,
    required this.isFavorite,
  });

  SongPlayerLoaded copyWith({
    String? songUrl,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    LoopMode? loopMode,
    bool? isShuffleEnabled,
    bool? isFavorite,
  }) {
    return SongPlayerLoaded(
      songUrl: songUrl ?? this.songUrl,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      loopMode: loopMode ?? this.loopMode,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongPlayerLoaded &&
          runtimeType == other.runtimeType &&
          songUrl == other.songUrl &&
          position == other.position &&
          duration == other.duration &&
          isPlaying == other.isPlaying &&
          loopMode == other.loopMode &&
          isShuffleEnabled == other.isShuffleEnabled &&
          isFavorite == other.isFavorite;

  @override
  int get hashCode =>
      songUrl.hashCode ^
      position.hashCode ^
      duration.hashCode ^
      isPlaying.hashCode ^
      loopMode.hashCode ^
      isShuffleEnabled.hashCode ^
      isFavorite.hashCode;
}

class SongPlayerError extends SongPlayerState {
  final String message;
  SongPlayerError(this.message);
}
