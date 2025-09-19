import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
import 'package:spotify/common/widgets/appbar/app_bar.dart';

import 'package:spotify/presentation/searchScreen/cubit/search_cubit.dart';
import 'package:spotify/presentation/searchScreen/cubit/search_state.dart';
import '../../../../../service_locator.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchSongCubit>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: BasicAppbar(title: Text('Search Songs')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          context.isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  context.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 20,
                              ),
                              border: InputBorder.none,
                              hintText: "Search...",
                              hintStyle: TextStyle(
                                color:
                                    context.isDarkMode
                                        ? Colors.grey
                                        : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            onChanged: (query) {
                              context.read<SearchSongCubit>().searchSongs(
                                query,
                              );
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.mic, color: Color(0xff42C83C)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Results
                  Expanded(
                    child: BlocBuilder<SearchSongCubit, SearchSongState>(
                      builder: (context, state) {
                        if (state is SearchSongLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xff42C83C),
                            ),
                          );
                        } else if (state is SearchSongLoaded) {
                          if (state.songs.isEmpty) {
                            return const Center(child: Text("No songs found"));
                          }
                          return ListView.builder(
                            itemCount: state.songs.length,
                            itemBuilder: (context, index) {
                              final song = state.songs[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    song.imageUrl ??
                                        "https://via.placeholder.com/150",
                                  ),
                                ),
                                title: Text(song.title ?? ""),
                                subtitle: Text(song.artist ?? ""),
                                trailing: IconButton(
                                  icon: const Icon(Icons.favorite_border),
                                  onPressed: () {
                                    // TODO: Integrate favorites later
                                  },
                                ),
                              );
                            },
                          );
                        } else if (state is SearchSongError) {
                          return Center(child: Text(state.message));
                        }
                        return const Center(child: Text("Search for songs"));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
