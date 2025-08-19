import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';
import 'package:spotify/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:spotify/presentation/song_player/bloc/song_player_state.dart';
import '../../../common/widgets/appbar/app_bar.dart';
import '../../../core/configs/theme/app_colors.dart';

class SongPlayerPage extends StatelessWidget {
  final List<SongEntity> playlist;
  final int startIndex;
  final SongEntity songEntity;

  const SongPlayerPage({
    super.key,
    required this.playlist,
    this.startIndex = 0,
    required this.songEntity,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              SongPlayerCubit()..loadPlaylist(playlist, startIndex: startIndex),
      child: const _SongPlayerView(),
    );
  }
}

class _SongPlayerView extends StatelessWidget {
  const _SongPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: BasicAppbar(
        title: const Text(
          'Now Playing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        action: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _songCover(),
            const SizedBox(height: 30),
            _songDetail(),
            const SizedBox(height: 20),
            Expanded(child: _songPlayer()),
          ],
        ),
      ),
    );
  }

  Widget _songCover() {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        if (state is! SongPlayerLoaded) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final song = state.currentSong;
        return Container(
          height: MediaQuery.of(context).size.height / 2.3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child:
                song.imageUrl.isNotEmpty
                    ? Image.network(song.imageUrl, fit: BoxFit.cover)
                    : Container(
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.music_note,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
          ),
        );
      },
    );
  }

  Widget _songDetail() {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        if (state is! SongPlayerLoaded) return const SizedBox.shrink();
        final song = state.currentSong;
        return Column(
          children: [
            Text(
              song.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              song.artist,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  Widget _songPlayer() {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        if (state is SongPlayerLoading)
          return const Center(child: CircularProgressIndicator());
        if (state is SongPlayerError)
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.white),
            ),
          );

        if (state is SongPlayerLoaded) {
          final position = state.position.inSeconds.toDouble();
          final duration = state.duration.inSeconds.toDouble();

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: AppColors.primary,
                  trackHeight: 3,
                ),
                child: Slider(
                  value: position.clamp(0, duration > 0 ? duration : 1.0),
                  min: 0.0,
                  max: duration > 0 ? duration : 1.0,
                  onChanged:
                      (value) => context.read<SongPlayerCubit>().seekTo(
                        Duration(seconds: value.toInt()),
                      ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDuration(state.position),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    formatDuration(state.duration),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color:
                          state.isShuffleEnabled
                              ? AppColors.primary
                              : Colors.white70,
                    ),
                    onPressed:
                        () => context.read<SongPlayerCubit>().toggleShuffle(),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.skip_previous,
                      size: 40,
                      color: Colors.white,
                    ),
                    onPressed:
                        () => context.read<SongPlayerCubit>().playPrevious(),
                  ),
                  GestureDetector(
                    onTap:
                        () => context.read<SongPlayerCubit>().playOrPauseSong(),
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.skip_next,
                      size: 40,
                      color: Colors.white,
                    ),
                    onPressed: () => context.read<SongPlayerCubit>().playNext(),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.repeat,
                      color:
                          state.loopMode == LoopMode.one
                              ? AppColors.primary
                              : Colors.white70,
                    ),
                    onPressed:
                        () => context.read<SongPlayerCubit>().toggleLoopMode(),
                  ),
                ],
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
























// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:spotify/common/widgets/appbar/app_bar.dart';
// import 'package:spotify/domain/entities/song/song_entity.dart';
// import 'package:spotify/presentation/song_player/bloc/song_player_cubit.dart';
// import 'package:spotify/presentation/song_player/bloc/song_player_state.dart';
// import '../../../core/configs/constants/app_urls.dart';
// import '../../../core/configs/theme/app_colors.dart';

// class SongPlayerPage extends StatefulWidget {
//   final SongEntity songEntity;

//   const SongPlayerPage({required this.songEntity, super.key});

//   @override
//   State<SongPlayerPage> createState() => _SongPlayerPageState();
// }

// class _SongPlayerPageState extends State<SongPlayerPage> {
//   late SongPlayerCubit _playerCubit;

//   @override
//   void initState() {
//     super.initState();
//     _playerCubit = SongPlayerCubit();

//     // Load the song from parameter
//     _playerCubit.loadSong(widget.songEntity);

//     //  Save last played song to Hive
//     // _playerCubit.saveLastSong(widget.songEntity);

//     //  Also load last played song (optional, if restoring)
//     _playerCubit.loadLastPlayedSong();
//   }

//   @override
//   void dispose() {
//     _playerCubit.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: BasicAppbar(
//         title: const Text('Now Playing', style: TextStyle(fontSize: 18)),
//         action: IconButton(
//           onPressed: () {},
//           icon: const Icon(Icons.more_vert_rounded),
//         ),
//       ),
//       body: BlocProvider.value(
//         value: _playerCubit,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               _songCover(),
//               const SizedBox(height: 20),
//               _songDetail(),
//               const SizedBox(height: 30),
//               Expanded(child: _songPlayer()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _songCover() {
//     final imageUrl = widget.songEntity.imageUrl;

//     if (imageUrl.isEmpty ||
//         imageUrl == 'file:///' ||
//         !(Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false)) {
//       // Show placeholder image if URL is invalid
//       return Container(
//         height: MediaQuery.of(context).size.height / 2.5,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(30),
//           color: Colors.grey, // placeholder color
//           // or use AssetImage as a fallback
//         ),
//         child: const Center(
//           child: Icon(Icons.music_note, size: 50, color: Colors.white),
//         ),
//       );
//     }

//     return Container(
//       height: MediaQuery.of(context).size.height / 2.5,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         image: DecorationImage(
//           fit: BoxFit.cover,
//           image: NetworkImage(imageUrl),
//         ),
//       ),
//     );
//   }

//   Widget _songDetail() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.songEntity.title,
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               widget.songEntity.artist,
//               style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _songPlayer() {
//     return BlocBuilder<SongPlayerCubit, SongPlayerState>(
//       builder: (context, state) {
//         if (state is SongPlayerLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (state is SongPlayerError) {
//           return const Center(child: Text('Failed to load song.'));
//         }

//         if (state is SongPlayerLoaded) {
//           final position = state.position.inSeconds.toDouble();
//           final duration = state.duration.inSeconds.toDouble();

//           return Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Slider(
//                 value: position > duration ? duration : position,
//                 min: 0.0,
//                 max: duration > 0 ? duration : 1.0,
//                 onChanged: (value) {
//                   context.read<SongPlayerCubit>().seekTo(
//                     Duration(seconds: value.toInt()),
//                   );
//                 },
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(formatDuration(state.position)),
//                   Text(formatDuration(state.duration)),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: () {
//                   context.read<SongPlayerCubit>().playOrPauseSong();
//                 },
//                 child: Container(
//                   height: 60,
//                   width: 60,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: AppColors.primary,
//                   ),
//                   child: Icon(
//                     state.isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: Colors.white,
//                     size: 32,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }

//         return const SizedBox.shrink();
//       },
//     );
//   }

//   String formatDuration(Duration duration) {
//     final minutes = duration.inMinutes.remainder(60);
//     final seconds = duration.inSeconds.remainder(60);
//     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//   }
// }

