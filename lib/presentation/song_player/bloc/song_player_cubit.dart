import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';
import 'package:spotify/presentation/song_player/bloc/song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _songDuration = Duration.zero;
  Duration _songPosition = Duration.zero;
  String _currentUrl = '';

  int _currentIndex = 0;
  List<SongEntity> _playlist = [];
  SongEntity get currentSong =>
      _playlist.isNotEmpty
          ? _playlist[_currentIndex]
          : throw Exception('No song loaded');

  List<int> _order = [];
  int _orderPos = 0;

  bool _isShuffle = false;
  late Box favoritesBox;
  late Box<SongEntity> lastSongBox;

  // subscriptions
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<bool>? _playingSub;

  SongPlayerCubit() : super(SongPlayerLoading()) {
    _initHive();
    _initStreams();
    loadLastPlayedSong();
  }

  void _initStreams() {
    _positionSub = _audioPlayer.positionStream.listen((position) {
      _songPosition = position;
      if (!isClosed) updateSongPlayer();
    });

    _playerStateSub = _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (_audioPlayer.loopMode == LoopMode.one) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else {
          playNext();
        }
      }
    });

    _durationSub = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _songDuration = duration;
        if (!isClosed) updateSongPlayer();
      }
    });

    _playingSub = _audioPlayer.playingStream.listen((_) {
      if (!isClosed) updateSongPlayer();
    });
  }

  // Build order array from playlist length. Keep current song position stable.
  void _buildOrder({required bool shuffle, int? currentOriginalIndex}) {
    final n = _playlist.length;
    if (n == 0) {
      _order = [];
      _orderPos = 0;
      return;
    }

    _order = List<int>.generate(n, (i) => i);

    if (shuffle) {
      _order.shuffle(Random());
    }

    final targetOriginal = currentOriginalIndex ?? _currentIndex;
    final found = _order.indexOf(targetOriginal);
    _orderPos = found >= 0 ? found : 0;
  }

  // Call this to load a playlist (prefer this over loadSong when you have multiple songs)
  Future<void> loadPlaylist(
    List<SongEntity> songs, {
    int startIndex = 0,
  }) async {
    if (songs.isEmpty) {
      emit(SongPlayerError("Playlist is empty"));
      return;
    }

    _playlist = List<SongEntity>.from(songs);
    _currentIndex = startIndex.clamp(0, _playlist.length - 1);
    _isShuffle = _audioPlayer.shuffleModeEnabled;
    _buildOrder(shuffle: _isShuffle, currentOriginalIndex: _currentIndex);

    // sync orderPos -> currentIndex from _order
    _currentIndex = _order[_orderPos];

    await _playCurrentIndex();
  }

  // Loads a single song (keeps playlist if already loaded)
  Future<void> loadSong(SongEntity song) async {
    // if playlist exists and contains the song, set indices accordingly.
    final idx = _playlist.indexWhere((s) => s.songUrl == song.songUrl);
    if (idx >= 0) {
      _currentIndex = idx;
      // find position in order
      _orderPos = _order.indexOf(_currentIndex);
      if (_orderPos < 0) _orderPos = 0;
    } else {
      // not part of playlist -> replace playlist with single song
      _playlist = [song];
      _currentIndex = 0;
      _buildOrder(shuffle: false, currentOriginalIndex: 0);
      _orderPos = 0;
    }

    await _playCurrentIndex();
  }

  // internal: actually set the audio player's URL to current index and emit state
  Future<void> _playCurrentIndex() async {
    if (_playlist.isEmpty) return;
    final song = _playlist[_currentIndex];
    _currentUrl = song.songUrl;

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

      // Save last played song to Hive if available
      try {
        if (Hive.isBoxOpen('last_song')) {
          final box = Hive.box<SongEntity>('last_song');
          box.put('current', song);
        } else {
          // attempt to open (safe)
          await Hive.openBox<SongEntity>(
            'last_song',
          ).then((b) => b.put('current', song));
        }
      } catch (_) {}

      emit(
        SongPlayerLoaded(
          songUrl: _currentUrl,
          position: _songPosition,
          duration:
              _songDuration > Duration.zero
                  ? _songDuration
                  : (_audioPlayer.duration ?? Duration.zero),
          isPlaying: _audioPlayer.playing,
          loopMode: _audioPlayer.loopMode,
          isShuffleEnabled: _isShuffle,
          isFavorite: _isFavoriteUrl(_currentUrl),
        ),
      );
    } catch (e) {
      emit(SongPlayerError("Error loading song: $e"));
    }
  }

  // play/pause
  void playOrPauseSong() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  // Seek
  void seekTo(Duration position) {
    _audioPlayer.seek(position);
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen('favorites')) {
      favoritesBox = await Hive.openBox('favorites');
    } else {
      favoritesBox = Hive.box('favorites');
    }

    if (!Hive.isBoxOpen('last_song')) {
      lastSongBox = await Hive.openBox<SongEntity>('last_song');
    } else {
      lastSongBox = Hive.box<SongEntity>('last_song');
    }
  }

  Future<void> loadLastPlayedSong() async {
    await _initHive(); // ensure boxes are ready

    final lastSong = lastSongBox.get('current');
    if (lastSong != null) {
      await loadSong(lastSong);
    }
  }

  // Next (respects _order which handles shuffle)
  Future<void> playNext() async {
    if (_playlist.isEmpty || _order.isEmpty) return;

    _orderPos = (_orderPos + 1) % _order.length;
    _currentIndex = _order[_orderPos];

    await _audioPlayer.stop(); // stop previous before new
    await _playCurrentIndex();
  }

  // Previous (respects _order)
  Future<void> playPrevious() async {
    if (_playlist.isEmpty || _order.isEmpty) return;

    _orderPos = (_orderPos - 1) < 0 ? _order.length - 1 : _orderPos - 1;
    _currentIndex = _order[_orderPos];

    await _audioPlayer.stop(); // stop previous before new
    await _playCurrentIndex();
  }

  // Cycle Repeat: off -> all -> one -> off
  void toggleLoopMode() {
    LoopMode newMode;
    if (_audioPlayer.loopMode == LoopMode.off) {
      newMode = LoopMode.all;
    } else if (_audioPlayer.loopMode == LoopMode.all) {
      newMode = LoopMode.one;
    } else {
      newMode = LoopMode.off;
    }
    _audioPlayer.setLoopMode(newMode);
    updateSongPlayer();
  }

  // Toggle shuffle: rebuild _order while keeping the current original index stable
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    _audioPlayer.setShuffleModeEnabled(_isShuffle);
    _buildOrder(shuffle: _isShuffle, currentOriginalIndex: _currentIndex);
    // ensure currentIndex matches the order
    _currentIndex = _order[_orderPos];
    updateSongPlayer();
  }

  // update UI state (called from streams)
  void updateSongPlayer() {
    if (_playlist.isEmpty) return;

    final songUrl = _playlist[_currentIndex].songUrl;
    _currentUrl = songUrl;

    emit(
      SongPlayerLoaded(
        songUrl: _currentUrl,
        position: _songPosition,
        duration:
            _songDuration > Duration.zero
                ? _songDuration
                : (_audioPlayer.duration ?? Duration.zero),
        isPlaying: _audioPlayer.playing,
        loopMode: _audioPlayer.loopMode,
        isShuffleEnabled: _isShuffle,
        isFavorite: _isFavoriteUrl(_currentUrl),
      ),
    );
  }

  // Favorite helper (safe if Hive box closed)
  bool _isFavoriteUrl(String url) {
    try {
      if (Hive.isBoxOpen('favorites')) {
        final b = Hive.box('favorites');
        return b.containsKey(url);
      }
    } catch (_) {}
    return false;
  }

  // Toggle favorite (persist)
  void toggleFavorite() {
    if (state is SongPlayerLoaded) {
      final current = state as SongPlayerLoaded;
      final url = _currentUrl;
      try {
        if (Hive.isBoxOpen('favorites')) {
          final box = Hive.box('favorites');
          if (current.isFavorite) {
            box.delete(url);
          } else {
            box.put(url, true);
          }
        } else {
          // open it then store
          Hive.openBox('favorites').then((b) {
            if (current.isFavorite) {
              b.delete(url);
            } else {
              b.put(url, true);
            }
            updateSongPlayer();
          });
          return;
        }
      } catch (_) {}
      emit(current.copyWith(isFavorite: !current.isFavorite));
    }
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _playingSub?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
