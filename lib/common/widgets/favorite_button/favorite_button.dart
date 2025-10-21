import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/bloc/favorite_button/favorite_button_cubit.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';

import '../../../core/configs/theme/app_colors.dart';
import '../../bloc/favorite_button/favorite_button_state.dart';

class FavoriteButton extends StatelessWidget {
  final SongEntity songEntity;
  final Function? function;
  const FavoriteButton({required this.songEntity, this.function, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => FavoriteButtonCubit()..initialize(songEntity.isFavorite),
      child: BlocBuilder<FavoriteButtonCubit, FavoriteButtonState>(
        builder: (context, state) {
          bool isFavorite = songEntity.isFavorite;

          if (state is FavoriteButtonUpdated) {
            isFavorite = state.isFavorite;
          }

          return IconButton(
            onPressed: () async {
              await context.read<FavoriteButtonCubit>().favoriteButtonUpdated(
                songEntity.songId,
              );
              if (function != null) {
                function!();
              }
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_outline_outlined,
              size: 25,
              color: AppColors.darkGrey,
            ),
          );
        },
      ),
    );
  }
}
