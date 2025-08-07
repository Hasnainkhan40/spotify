// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class SongEntity {
  final String title;
  final String artist;
  final String imageUrl;
  final num duration;
  final Timestamp releaseDate;
  final bool isFavorite;
  final String songId;
  final String songUrl;

  SongEntity({
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.duration,
    required this.releaseDate,
    required this.isFavorite,
    required this.songId,
    required this.songUrl,
  });
}
