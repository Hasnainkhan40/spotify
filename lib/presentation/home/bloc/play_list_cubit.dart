import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/usecases/song/get_play_list.dart';
import '../../../service_locator.dart';
import 'play_list_state.dart';

class PlayListCubit extends Cubit<PlayListState> {
  PlayListCubit() : super(PlayListLoading());

  Future<void> getPlayList() async {
    // Start loading
    if (isClosed) return;
    emit(PlayListLoading());

    var returnedSongs = await sl<GetPlayListUseCase>().call();

    // Check again after async
    if (isClosed) return;

    returnedSongs.fold(
      (l) {
        if (isClosed) return;
        emit(PlayListLoadFailure());
      },
      (data) {
        if (isClosed) return;
        emit(PlayListLoaded(songs: data));
      },
    );
  }
}
