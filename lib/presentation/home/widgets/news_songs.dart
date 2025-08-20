import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
// import 'package:spotify/core/configs/constants/app_urls.dart';
import 'package:spotify/core/configs/theme/app_colors.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';
import 'package:spotify/presentation/home/bloc/news_songs_cubit.dart';
import 'package:spotify/presentation/song_player/pages/song_player.dart';
// import 'package:spotify/presentation/song_player/pages/song_player.dart';

// import '../../../domain/entities/song/song.dart';
import '../bloc/news_songs_state.dart';

class NewsSongs extends StatelessWidget {
  const NewsSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsSongsCubit()..getNewsSongs(),
      child: SizedBox(
        height: 200,
        child: BlocBuilder<NewsSongsCubit, NewsSongsState>(
          builder: (context, state) {
            if (state is NewsSongsLoading) {
              return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            }

            if (state is NewsSongsLoaded) {
              return songs(state.songs);
            }

            return Icon(Icons.error);
          },
        ),
      ),
    );
  }

  Widget songs(List<SongEntity> songs) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            final song = songs[index];

            // Save the song to Hive
            Hive.box<SongEntity>('last_song').put('current', song);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (BuildContext context) => SongPlayerPage(
                      songEntity: songs[index], // tapped song
                      playlist: songs, // full playlist
                      startIndex: index, // start at this song
                    ),
              ),
            );
          },
          child: SizedBox(
            width: 160,
            height: 200, // <-- Add this to prevent vertical overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    height: 200, // <-- Adjust image height
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(songs[index].imageUrl),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 40,
                        width: 40,
                        transform: Matrix4.translationValues(10, 10, 0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              context.isDarkMode
                                  ? AppColors.darkGrey
                                  : const Color(0xffE6E6E6),
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color:
                              context.isDarkMode
                                  ? const Color(0xff959595)
                                  : const Color(0xff555555),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  songs[index].title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  songs[index].artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 14),
      itemCount: songs.length,
    );
  }
}
