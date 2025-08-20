import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify/common/widgets/appbar/app_bar.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';
import 'package:spotify/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:spotify/presentation/song_player/bloc/song_player_state.dart';
import '../../../core/configs/theme/app_colors.dart';

class SongPlayerPage extends StatefulWidget {
  final SongEntity songEntity;
  final List<SongEntity>? playlist;
  final int startIndex;

  const SongPlayerPage({
    required this.songEntity,
    this.playlist,
    this.startIndex = 0,
    super.key,
  });

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  late final SongPlayerCubit _playerCubit;

  @override
  void initState() {
    super.initState();
    _playerCubit = SongPlayerCubit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize playlist after the widget tree is built
      if (widget.playlist != null && widget.playlist!.isNotEmpty) {
        final safeStart = widget.startIndex.clamp(
          0,
          widget.playlist!.length - 1,
        );
        _playerCubit.loadPlaylist(widget.playlist!, startIndex: safeStart);
      } else {
        _playerCubit.loadPlaylist([widget.songEntity], startIndex: 0);
      }
    });
  }

  @override
  void dispose() {
    _playerCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SongPlayerCubit>.value(
      value: _playerCubit,
      child: Scaffold(
        appBar: BasicAppbar(
          title: const Text('Now Playing', style: TextStyle(fontSize: 18)),
          action: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<SongPlayerCubit, SongPlayerState>(
            builder: (context, state) {
              if (state is SongPlayerLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SongPlayerError) {
                return Center(child: Text(state.message));
              }

              if (state is SongPlayerLoaded) {
                final song = _playerCubit.currentSong;
                final position = state.position.inSeconds.toDouble();
                final duration = state.duration.inSeconds.toDouble();

                IconData repeatIcon;
                Color repeatColor = Colors.white;
                if (state.loopMode == LoopMode.one) {
                  repeatIcon = Icons.repeat_one;
                  repeatColor = AppColors.primary;
                } else if (state.loopMode == LoopMode.all) {
                  repeatIcon = Icons.repeat;
                  repeatColor = AppColors.primary;
                } else {
                  repeatIcon = Icons.repeat;
                  repeatColor = Colors.white;
                }

                final shuffleColor =
                    state.isShuffleEnabled ? AppColors.primary : Colors.white;

                return Column(
                  children: [
                    // Song Cover
                    _songCover(song),

                    const SizedBox(height: 20),

                    // Song Details
                    _songDetail(song),

                    const SizedBox(height: 30),

                    // Player Controls
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Favorite button top-right
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(
                                state.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Color(0xff42C83C),
                              ),
                              onPressed: () {
                                context
                                    .read<SongPlayerCubit>()
                                    .toggleFavorite();
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Slider
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  thumbColor: Color(0xff42C83C),
                                  activeColor: Color(0xff42C83C),
                                  value:
                                      position > duration ? duration : position,
                                  min: 0.0,
                                  max: duration > 0 ? duration : 1.0,
                                  onChanged: (value) {
                                    context.read<SongPlayerCubit>().seekTo(
                                      Duration(seconds: value.toInt()),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          // Time Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDuration(state.position),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                formatDuration(state.duration),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Controls Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(Icons.shuffle),
                                color: shuffleColor,
                                onPressed:
                                    () =>
                                        context
                                            .read<SongPlayerCubit>()
                                            .toggleShuffle(),
                              ),
                              IconButton(
                                icon: Icon(Icons.skip_previous, size: 34),
                                onPressed:
                                    () =>
                                        context
                                            .read<SongPlayerCubit>()
                                            .playPrevious(),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context
                                      .read<SongPlayerCubit>()
                                      .playOrPauseSong();
                                },
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff42C83C),
                                  ),
                                  child: Icon(
                                    state.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.skip_next, size: 34),
                                onPressed:
                                    () =>
                                        context
                                            .read<SongPlayerCubit>()
                                            .playNext(),
                              ),
                              IconButton(
                                icon: Icon(repeatIcon),
                                color: repeatColor,
                                onPressed:
                                    () =>
                                        context
                                            .read<SongPlayerCubit>()
                                            .toggleLoopMode(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _songCover(SongEntity song) {
    final imageUrl = song.imageUrl;
    if (imageUrl.isEmpty ||
        imageUrl == 'file:///' ||
        !(Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false)) {
      return Container(
        height: MediaQuery.of(context).size.height / 2.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey,
        ),
        child: const Center(
          child: Icon(Icons.music_note, size: 50, color: Colors.white),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height / 2.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(imageUrl),
        ),
      ),
    );
  }

  Widget _songDetail(SongEntity song) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              song.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 5),
            Text(
              song.artist,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:spotify/common/widgets/appbar/app_bar.dart';
// import 'package:spotify/domain/entities/song/song_entity.dart';
// import 'package:spotify/presentation/song_player/bloc/song_player_cubit.dart';
// import 'package:spotify/presentation/song_player/bloc/song_player_state.dart';
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

//     // Optional: load last played song
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
//       return Container(
//         height: MediaQuery.of(context).size.height / 2.5,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(30),
//           color: Colors.grey,
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
//               // Slider + Heart
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: IconButton(
//                   icon: Icon(
//                     state.isFavorite ? Icons.favorite : Icons.favorite_border,
//                     color: Colors.red,
//                   ),
//                   onPressed: () {
//                     context.read<SongPlayerCubit>().toggleFavorite();
//                   },
//                 ),
//               ),
//               SizedBox(height: 22),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Slider(
//                       value: position > duration ? duration : position,
//                       min: 0.0,
//                       max: duration > 0 ? duration : 1.0,
//                       onChanged: (value) {
//                         context.read<SongPlayerCubit>().seekTo(
//                           Duration(seconds: value.toInt()),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),

//               // Time Row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     formatDuration(state.position),
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                   Text(
//                     formatDuration(state.duration),
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),

//               // Control Buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.shuffle),
//                     onPressed:
//                         () => context.read<SongPlayerCubit>().toggleShuffle(),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.skip_previous),
//                     onPressed:
//                         () => context.read<SongPlayerCubit>().playPrevious(),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       context.read<SongPlayerCubit>().playOrPauseSong();
//                     },
//                     child: Container(
//                       height: 70,
//                       width: 70,
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white,
//                       ),
//                       child: Icon(
//                         state.isPlaying ? Icons.pause : Icons.play_arrow,
//                         color: Colors.black,
//                         size: 40,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.skip_next),
//                     onPressed: () => context.read<SongPlayerCubit>().playNext(),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.repeat),
//                     onPressed:
//                         () => context.read<SongPlayerCubit>().toggleLoopMode(),
//                   ),
//                 ],
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

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:spotify/common/widgets/appbar/app_bar.dart';
// import 'package:spotify/domain/entities/song/song_entity.dart';
// import 'package:spotify/presentation/song_player/bloc/song_player_cubit.dart';
// import 'package:spotify/presentation/song_player/bloc/song_player_state.dart';
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
