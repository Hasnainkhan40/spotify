import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify/core/configs/theme/app_theme.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';
import 'package:spotify/firebase_options.dart';
import 'package:spotify/presentation/addSongs/bloc/addsong_bloc.dart';
import 'package:spotify/presentation/chatAi/bloc/chat_bloc.dart';
import 'package:spotify/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:spotify/presentation/forget_pas.dart/bloc/auth_bloc.dart';
import 'package:spotify/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:spotify/presentation/splash/pages/splash.dart';
import 'package:spotify/service_locator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getTemporaryDirectory(),
  );
  HydratedBloc.storage = storage;

  // Firebase Init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Service Locator Init
  await initializeDependencies();

  // Hive Init
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);

  Hive.registerAdapter(SongEntityAdapter());

  await Hive.openBox('favorites');
  await Hive.openBox<SongEntity>('last_song');

  await initDependencies(
    geminiApiKey: 'AIzaSyCAjdzK8HHZEGysMadbED51_XnF_zuuw3Q',
  );
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<ChatBloc>()),
        BlocProvider(create: (_) => SongPlayerCubit()),
        BlocProvider<StoreSongBloc>(create: (_) => sl<StoreSongBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            debugShowCheckedModeBanner: false,
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
