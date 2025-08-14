abstract class SongPlayerState {}

class SongPlayerLoading extends SongPlayerState {}

class SongPlayerLoaded extends SongPlayerState {
  final String songUrl;
  final Duration position;
  final Duration duration;
  final bool isPlaying;

  SongPlayerLoaded({
    required this.songUrl,
    required this.position,
    required this.duration,
    required this.isPlaying,
  });

  SongPlayerLoaded copyWith({
    String? songUrl,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
  }) {
    return SongPlayerLoaded(
      songUrl: songUrl ?? this.songUrl,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class SongPlayerError extends SongPlayerState {
  final String message;
  SongPlayerError(this.message);
}















// abstract class SongPlayerState {}

// class SongPlayerLoading extends SongPlayerState {}

// class SongPlayerLoaded extends SongPlayerState {}

// class SongPlayerFailure extends SongPlayerState {}