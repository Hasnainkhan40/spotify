import 'package:get_it/get_it.dart';
import 'package:spotify/data/repository/auth/auth_repository_impl.dart';
import 'package:spotify/data/repository/chat_repository_impl.dart';
import 'package:spotify/data/sources/auth/auth_firebase_service.dart';
import 'package:spotify/data/sources/chat_remote_datasource.dart';
import 'package:spotify/domain/repository/auth/auth.dart';
import 'package:spotify/domain/repository/chat_repository.dart';
import 'package:spotify/domain/usecases/auth/get_user.dart';
import 'package:spotify/domain/usecases/auth/signup.dart';
import 'package:spotify/domain/usecases/auth/update_pass.dart';
import 'package:spotify/domain/usecases/send_message_usecase.dart';
import 'package:spotify/domain/usecases/song/add_or_remove_favorite_song.dart';
import 'package:spotify/domain/usecases/song/get_favorite_songs.dart';
import 'package:spotify/domain/usecases/song/get_news_songs.dart';
import 'package:spotify/domain/usecases/song/get_play_list.dart';
import 'package:spotify/domain/usecases/song/is_favorite_song.dart';
import 'package:spotify/domain/usecases/song/search_song_usecase.dart';
import 'package:spotify/domain/usecases/song/store_song.dart';
import 'package:spotify/presentation/addSongs/bloc/addsong_bloc.dart';
import 'package:spotify/presentation/chatAi/bloc/chat_bloc.dart';
import 'package:spotify/presentation/forget_pas.dart/bloc/auth_bloc.dart';
import 'package:spotify/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:spotify/presentation/searchScreen/cubit/search_cubit.dart';
import 'data/repository/song/song_repository_impl.dart';
import 'data/sources/song/song_firebase_service.dart';
import 'domain/repository/song/song.dart';
import 'domain/usecases/auth/sigin.dart';

final sl = GetIt.instance;

Future<void> initDependencies({required String geminiApiKey}) async {
  // Data layer
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(geminiApiKey),
  );

  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));

  // Domain
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));

  // Presentation
  sl.registerFactory(() => ChatBloc(sendMessageUseCase: sl()));
}

Future<void> initializeDependencies() async {
  // Services
  if (!sl.isRegistered<AuthFirebaseService>()) {
    sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  }

  if (!sl.isRegistered<SongFirebaseService>()) {
    sl.registerSingleton<SongFirebaseService>(SongFirebaseServiceImpl());
  }

  // Repositories
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  }

  if (!sl.isRegistered<SongsRepository>()) {
    sl.registerLazySingleton<SongsRepository>(() => SongRepositoryImpl());
  }

  // Auth use cases
  if (!sl.isRegistered<ResetPasswordUseCase>()) {
    sl.registerSingleton<ResetPasswordUseCase>(
      ResetPasswordUseCase(sl<AuthRepository>()),
    );
  }

  if (!sl.isRegistered<SignupUseCase>()) {
    sl.registerSingleton<SignupUseCase>(SignupUseCase());
  }

  if (!sl.isRegistered<SigninUseCase>()) {
    sl.registerSingleton<SigninUseCase>(SigninUseCase());
  }

  if (!sl.isRegistered<GetUserUseCase>()) {
    sl.registerSingleton<GetUserUseCase>(GetUserUseCase());
  }

  // Song use cases
  if (!sl.isRegistered<GetNewsSongsUseCase>()) {
    sl.registerSingleton<GetNewsSongsUseCase>(GetNewsSongsUseCase());
  }

  if (!sl.isRegistered<GetPlayListUseCase>()) {
    sl.registerSingleton<GetPlayListUseCase>(GetPlayListUseCase());
  }

  if (!sl.isRegistered<AddOrRemoveFavoriteSongUseCase>()) {
    sl.registerSingleton<AddOrRemoveFavoriteSongUseCase>(
      AddOrRemoveFavoriteSongUseCase(),
    );
  }

  if (!sl.isRegistered<IsFavoriteSongUseCase>()) {
    sl.registerSingleton<IsFavoriteSongUseCase>(IsFavoriteSongUseCase());
  }

  if (!sl.isRegistered<GetFavoriteSongsUseCase>()) {
    sl.registerSingleton<GetFavoriteSongsUseCase>(GetFavoriteSongsUseCase());
  }

  if (!sl.isRegistered<StoreSongUseCase>()) {
    sl.registerLazySingleton(() => StoreSongUseCase(sl<SongsRepository>()));
  }

  if (!sl.isRegistered<SearchSongUseCase>()) {
    sl.registerLazySingleton(() => SearchSongUseCase(sl<SongsRepository>()));
  }

  // Blocs / Cubits
  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory<AuthBloc>(
      () => AuthBloc(resetPasswordUseCase: sl<ResetPasswordUseCase>()),
    );
  }

  if (!sl.isRegistered<StoreSongBloc>()) {
    sl.registerFactory<StoreSongBloc>(
      () => StoreSongBloc(storeSongUseCase: sl<StoreSongUseCase>()),
    );
  }

  if (!sl.isRegistered<SearchSongCubit>()) {
    sl.registerFactory(() => SearchSongCubit(sl<SearchSongUseCase>()));
  }

  if (!sl.isRegistered<ProfileInfoCubit>()) {
    sl.registerFactory(
      () => ProfileInfoCubit(getUserUseCase: sl<GetUserUseCase>()),
    );
  }
}

// final sl = GetIt.instance;

// Future<void> initializeDependencies() async {
//   // Services
//   sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());

//   sl.registerSingleton<SongFirebaseService>(SongFirebaseServiceImpl());

//   // Repositories
//   // sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

//   // sl.registerSingleton<SongsRepository>(SongRepositoryImpl());

//   sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
//   sl.registerLazySingleton<SongsRepository>(() => SongRepositoryImpl());

//   // Auth use cases
//   sl.registerSingleton<ResetPasswordUseCase>(
//     ResetPasswordUseCase(sl<AuthRepository>()),
//   );

//   sl.registerSingleton<SignupUseCase>(SignupUseCase());

//   sl.registerSingleton<SigninUseCase>(SigninUseCase());

//   sl.registerSingleton<GetUserUseCase>(GetUserUseCase());

//   // Song use cases
//   sl.registerSingleton<GetNewsSongsUseCase>(GetNewsSongsUseCase());

//   sl.registerSingleton<GetPlayListUseCase>(GetPlayListUseCase());

//   sl.registerSingleton<AddOrRemoveFavoriteSongUseCase>(
//     AddOrRemoveFavoriteSongUseCase(),
//   );

//   sl.registerSingleton<IsFavoriteSongUseCase>(IsFavoriteSongUseCase());

//   sl.registerSingleton<GetFavoriteSongsUseCase>(GetFavoriteSongsUseCase());

//   sl.registerLazySingleton(() => StoreSongUseCase(sl<SongsRepository>()));

//   // Blocs
//   sl.registerFactory<AuthBloc>(
//     () => AuthBloc(resetPasswordUseCase: sl<ResetPasswordUseCase>()),
//   );

//   sl.registerFactory<StoreSongBloc>(
//     () => StoreSongBloc(storeSongUseCase: sl<StoreSongUseCase>()),
//   );
//   // Repositories
//   sl.registerLazySingleton<SongsRepository>(() => SongRepositoryImpl());

//   // Song use cases
//   sl.registerLazySingleton(() => SearchSongUseCase(sl<SongsRepository>()));

//   // Cubits / Blocs
//   sl.registerFactory(() => SearchSongCubit(sl<SearchSongUseCase>()));
// }
