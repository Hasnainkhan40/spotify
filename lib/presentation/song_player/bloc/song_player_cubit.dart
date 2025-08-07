import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _songDuration = Duration.zero;
  Duration _songPosition = Duration.zero;
  String _currentUrl =
      'https://www.billboard.com/wp-content/uploads/2023/06/the-weeknd-may-2023-billboard-1548.jpg?w=942&h=628&crop=1';

  SongPlayerCubit() : super(SongPlayerLoading()) {
    _audioPlayer.positionStream.listen((position) {
      _songPosition = position;
      updateSongPlayer();
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _songDuration = duration;
      }
    });
  }

  Future<void> loadSong(String url) async {
    _currentUrl = url;
    try {
      await _audioPlayer.setUrl(url);
      emit(
        SongPlayerLoaded(
          position: _songPosition,
          duration: _songDuration,
          isPlaying: _audioPlayer.playing,
          songUrl: url,
        ),
      );
    } catch (e) {
      emit(SongPlayerFailure());
    }
  }

  void playOrPauseSong() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    updateSongPlayer();
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