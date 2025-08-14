import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/usecases/song/store_song.dart';
import 'package:spotify/presentation/addSongs/bloc/addsong_event.dart';
import 'package:spotify/presentation/addSongs/bloc/addsong_state.dart';

class StoreSongBloc extends Bloc<StoreSongEvent, StoreSongState> {
  final StoreSongUseCase storeSongUseCase;

  StoreSongBloc({required this.storeSongUseCase}) : super(StoreSongInitial()) {
    on<StoreSongRequested>((event, emit) async {
      emit(StoreSongLoading());

      final result = await storeSongUseCase(event.song);

      result.fold(
        (error) => emit(StoreSongFailure(error)),
        (_) => emit(StoreSongSuccess()),
      );
    });
  }
}
