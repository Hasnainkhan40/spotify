// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';

class SongModel {
  String? title;
  String? artist;
  String? imageUrl;
  num? duration;
  Timestamp? releaseDate;
  bool? isFavorite;
  String? songId;
  String? songUrl;

  SongModel({
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.duration,
    required this.releaseDate,
    required this.isFavorite,
    required this.songId,
    required this.songUrl,
  });

  // Firestore -> Model
  SongModel.fromJson(Map<String, dynamic> data) {
    title = data['title'] ?? '';
    artist = data['artist'] ?? '';
    imageUrl = data['imageUrl'] ?? '';
    duration = data['duration'] ?? 0;
    releaseDate = data['releaseDate'] ?? Timestamp.now();
    isFavorite = data['isFavorite'] ?? false;
    songId = data['songId'] ?? '';
    songUrl = data['songUrl'] ?? '';
  }

  // Model -> Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'imageUrl': imageUrl,
      'duration': duration,
      'releaseDate': releaseDate,
      'isFavorite': isFavorite,
      'songId': songId,
      'songUrl': songUrl,
    };
  }

  // Entity -> Model
  factory SongModel.fromEntity(SongEntity entity) {
    return SongModel(
      title: entity.title,
      artist: entity.artist,
      imageUrl: entity.imageUrl,
      duration: entity.duration,
      releaseDate: Timestamp.fromDate(entity.releaseDate),
      isFavorite: entity.isFavorite,
      songId: entity.songId,
      songUrl: entity.songUrl,
    );
  }
}

// Model -> Entity
extension SongModelX on SongModel {
  SongEntity toEntity() {
    return SongEntity(
      title: title!,
      artist: artist!,
      imageUrl: imageUrl!,
      duration: duration!,
      releaseDate: releaseDate!.toDate(),
      isFavorite: isFavorite!,
      songId: songId!,
      songUrl: songUrl!,
    );
  }
}
