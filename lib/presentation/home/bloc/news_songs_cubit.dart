import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/usecases/song/get_news_songs.dart';
import 'package:spotify/presentation/home/bloc/news_songs_state.dart';

import '../../../service_locator.dart';

class NewsSongsCubit extends Cubit<NewsSongsState> {
  NewsSongsCubit() : super(NewsSongsLoading());

  Future<void> getNewsSongs() async {
    emit(NewsSongsLoading());

    final result = await sl<GetNewsSongsUseCase>().call();

    result.fold(
      (failure) {
        emit(NewsSongsLoadFailure());
      },
      (songs) {
        emit(NewsSongsLoaded(songs: songs));
      },
    );
  }
}
