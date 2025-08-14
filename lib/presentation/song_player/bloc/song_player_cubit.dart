import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';
import 'package:spotify/presentation/song_player/bloc/song_player_state.dart';

/*
Next/previous track handling
Loop/shuffle modes
Favorite toggle
Error logging or retries*/

class SongPlayerCubit extends Cubit<SongPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _songDuration = Duration.zero;
  Duration _songPosition = Duration.zero;
  String _currentUrl = '';

  SongPlayerCubit() : super(SongPlayerLoading()) {
    _audioPlayer.positionStream.listen((position) {
      _songPosition = position;
      updateSongPlayer();
    });
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _audioPlayer.pause();
        _audioPlayer.seek(Duration.zero);
        updateSongPlayer();
      }
    });
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _songDuration = duration;
        updateSongPlayer(); // Notify UI about duration change
      }
    });
    _audioPlayer.playingStream.listen((playing) {
      updateSongPlayer();
    });
  }

  Future<void> loadSong(SongEntity song) async {
    _currentUrl = song.songUrl;

    if (_currentUrl.isEmpty) {
      emit(SongPlayerError("Invalid song URL"));
      return;
    }

    try {
      // Handle local file URLs differently if needed
      if (_currentUrl.startsWith('file://')) {
        final filePath = _currentUrl.replaceFirst('file://', '');
        final file = File(filePath);
        if (!file.existsSync()) {
          emit(SongPlayerError("Local file not found"));
          return;
        }
        await _audioPlayer.setFilePath(filePath);
      } else {
        await _audioPlayer.setUrl(_currentUrl);
      }

      // Save last played song
      final box = Hive.box<SongEntity>('last_song');
      box.put('current', song);

      emit(
        SongPlayerLoaded(
          position: _songPosition,
          duration: _songDuration,
          isPlaying: _audioPlayer.playing,
          songUrl: _currentUrl,
        ),
      );
    } catch (e) {
      emit(SongPlayerError(e.toString()));
    }
  }

  Future<void> loadLastPlayedSong() async {
    final box = Hive.box<SongEntity>('last_song');
    final lastSong = box.get('current');

    if (lastSong != null) {
      _currentUrl = lastSong.songUrl;

      if (_currentUrl.isEmpty) {
        emit(SongPlayerError("Invalid last played song URL"));
        return;
      }

      try {
        if (_currentUrl.startsWith('file://')) {
          final filePath = _currentUrl.replaceFirst('file://', '');
          final file = File(filePath);
          if (!file.existsSync()) {
            emit(SongPlayerError("Local file not found"));
            return;
          }
          await _audioPlayer.setFilePath(filePath);
        } else {
          await _audioPlayer.setUrl(_currentUrl);
        }

        _songDuration = _audioPlayer.duration ?? Duration.zero;

        emit(
          SongPlayerLoaded(
            position: Duration.zero,
            duration: _songDuration,
            isPlaying: false,
            songUrl: _currentUrl,
          ),
        );
      } catch (e) {
        emit(SongPlayerError(e.toString()));
      }
    }
  }
  //   void saveLastSong(SongEntity song) {
  //   final box = Hive.box<SongEntity>('last_song');
  //   box.put('current', song);
  // }

  void playOrPauseSong() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    // No need to call updateSongPlayer here, it will be triggered by playingStream listener
  }

  void updateSongPlayer() {
    emit(
      SongPlayerLoaded(
        position: _songPosition,
        duration: _songDuration,
        isPlaying: _audioPlayer.playing,
        songUrl: _currentUrl,
      ),
    );
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }

  void seekTo(Duration position) {
    _audioPlayer.seek(position);
  }
}

























// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:just_audio/just_audio.dart';
// import 'song_player_state.dart';

// class SongPlayerCubit extends Cubit<SongPlayerState> {
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   Duration _songDuration = Duration.zero;
//   Duration _songPosition = Duration.zero;
//   String _currentUrl = '';

//   SongPlayerCubit() : super(SongPlayerLoading()) {
//     _audioPlayer.positionStream.listen((position) {
//       _songPosition = position;
//       updateSongPlayer();
//     });

//     _audioPlayer.durationStream.listen((duration) {
//       if (duration != null) {
//         _songDuration = duration;
//       }
//     });
//   }

//   Future<void> loadSong(String url) async {
//     _currentUrl = url;
//     try {
//       await _audioPlayer.setUrl(url);
//       emit(
//         SongPlayerLoaded(
//           position: _songPosition,
//           duration: _songDuration,
//           isPlaying: _audioPlayer.playing,
//           songUrl: url,
//         ),
//       );
//     } catch (e) {
//       emit(SongPlayerFailure());
//     }
//   }

//   void playOrPauseSong() {
//     if (_audioPlayer.playing) {
//       _audioPlayer.pause();
//     } else {
//       _audioPlayer.play();
//     }
//     updateSongPlayer();
//   }

//   void updateSongPlayer() {
//     emit(
//       SongPlayerLoaded(
//         position: _songPosition,
//         duration: _songDuration,
//         isPlaying: _audioPlayer.playing,
//         songUrl: _currentUrl,
//       ),
//     );
//   }

//   @override
//   Future<void> close() {
//     _audioPlayer.dispose();
//     return super.close();
//   }

//   void seekTo(Duration position) {
//     _audioPlayer.seek(position);
//   }
// }






















// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:spotify/presentation/song_player/bloc/song_player_state.dart';

// class SongPlayerCubit extends Cubit<SongPlayerState> {

//   AudioPlayer audioPlayer = AudioPlayer();

//   Duration songDuration = Duration.zero;
//   Duration songPosition = Duration.zero;

//   SongPlayerCubit() : super(SongPlayerLoading()) {

//     audioPlayer.positionStream.listen((position) { 
//       songPosition = position;
//       updateSongPlayer();
//     });

//     audioPlayer.durationStream.listen((duration) { 
//       songDuration = duration!;
//     });
//   }

//   void updateSongPlayer() {
//     emit(
//       SongPlayerLoaded()
//     );
//   }


//   Future<void> loadSong(String url) async{
//     print(url);
//     try {
//       await audioPlayer.setUrl(url);
//       emit(
//         SongPlayerLoaded()
//       );
//     } catch(e){
//       emit(
//         SongPlayerFailure()
//       );
//     }
//   }

//   void playOrPauseSong() {
//     if (audioPlayer.playing) {
//       audioPlayer.stop();
//     } else {
//       audioPlayer.play();
//     }
//     emit(
//       SongPlayerLoaded()
//     );
//   }
  
//   @override
//   Future<void> close() {
//     audioPlayer.dispose();
//     return super.close();
//   }
// }