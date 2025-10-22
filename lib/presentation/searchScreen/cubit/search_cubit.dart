import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/data/models/song/song.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';
import 'package:spotify/domain/usecases/song/search_song_usecase.dart';
import 'package:spotify/presentation/searchScreen/cubit/search_state.dart';

class SearchSongCubit extends Cubit<SearchSongState> {
  final SearchSongUseCase searchSongUseCase;
  List<SongEntity> allSongs = [];

  SearchSongCubit(this.searchSongUseCase) : super(SearchSongInitial());
  Future<void> searchSongs(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchSongInitial());
      return;
    }

    if (allSongs.isEmpty) {
      final snapshot =
          await FirebaseFirestore.instance.collection('songs').get();
      allSongs =
          snapshot.docs.map((doc) {
            final model = SongModel.fromJson(doc.data());
            model.songId = doc.id;
            return model.toEntity();
          }).toList();
    }

    final normalizedQuery = query.toLowerCase();
    final filtered =
        allSongs.where((song) {
          return song.title?.toLowerCase().contains(normalizedQuery) == true ||
              song.artist?.toLowerCase().contains(normalizedQuery) == true;
        }).toList();

    emit(SearchSongLoaded(filtered));
  }
}
