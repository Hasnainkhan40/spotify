import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:spotify/core/configs/assets/app_vectors.dart';
import 'package:spotify/presentation/home/pages/homescreen.dart';
import 'package:spotify/presentation/intro/pages/get_started.dart'; // Optional: use if needed
import 'package:spotify/presentation/auth/pages/signin.dart';
import 'package:spotify/presentation/song_player/bloc/song_player_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SongPlayerCubit>().loadLastPlayedSong(); // ✅ Load last song
      redirect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: SvgPicture.asset(AppVectors.logo)));
  }

  Future<void> redirect() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      // ✅ Already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // 👤 Not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GetStartedPage()),
      );
    }
  }
}
