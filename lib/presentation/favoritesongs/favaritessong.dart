import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify/presentation/profile/bloc/favorite_songs_cubit.dart';
import 'package:spotify/presentation/profile/bloc/favorite_songs_state.dart';
import 'package:spotify/presentation/song_player/pages/song_player.dart';

class Favaritessong extends StatelessWidget {
  const Favaritessong({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: _favoriteSongs(),
      ),
    );
  }
}

Widget _favoriteSongs() {
  return BlocProvider(
    create: (context) => FavoriteSongsCubit()..getFavoriteSongs(),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 100),
            child: const Text('FAVORITE SONGS', style: TextStyle(fontSize: 20)),
          ),

          const SizedBox(height: 15),
          BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
            builder: (context, state) {
              if (state is FavoriteSongsLoading) {
                return const CircularProgressIndicator();
              }
              if (state is FavoriteSongsLoaded) {
                return ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (BuildContext context) => SongPlayerPage(
                                  songEntity: state.favoriteSongs[index],
                                  playlist: [],
                                ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      state.favoriteSongs[index].imageUrl,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.favoriteSongs[index].title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    state.favoriteSongs[index].artist,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                state.favoriteSongs[index].duration
                                    .toString()
                                    .replaceAll('.', ':'),
                              ),
                              const SizedBox(width: 20),
                              FavoriteButton(
                                songEntity: state.favoriteSongs[index],
                                key: UniqueKey(),
                                function: () {
                                  context.read<FavoriteSongsCubit>().removeSong(
                                    index,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 20),
                  itemCount: state.favoriteSongs.length,
                );
              }
              if (state is FavoriteSongsFailure) {
                return const Text('Please try again.');
              }
              return Container();
            },
          ),
        ],
      ),
    ),
  );
}
