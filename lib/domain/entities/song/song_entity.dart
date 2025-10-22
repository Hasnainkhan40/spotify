import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'song_entity.g.dart';

@HiveType(typeId: 0)
class SongEntity extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String artist;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final num duration;

  @HiveField(4)
  final DateTime releaseDate;

  @HiveField(5)
  final bool isFavorite;

  @HiveField(6)
  final String songId;

  @HiveField(7)
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

  /// Factory method to create SongEntity from Firestore document
  factory SongEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Convert Firestore Timestamp to DateTime
    final Timestamp? timestamp = data['releaseDate'] as Timestamp?;

    return SongEntity(
      title: data['title'] ?? '',
      artist: data['artist'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      duration: (data['duration'] ?? 0) as num,
      releaseDate: timestamp?.toDate() ?? DateTime.now(),
      isFavorite: data['isFavorite'] ?? false,
      songId: doc.id,
      songUrl: data['songUrl'] ?? '',
    );
  }

  /// Convert SongEntity to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'imageUrl': imageUrl,
      'duration': duration,
      'releaseDate': Timestamp.fromDate(releaseDate),
      'isFavorite': isFavorite,
      'songUrl': songUrl,
    };
  }
}














// import 'package:hive/hive.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// part 'song_entity.g.dart';

// @HiveType(typeId: 0)
// class SongEntity extends HiveObject {
//   @HiveField(0)
//   final String title;

//   @HiveField(1)
//   final String artist;

//   @HiveField(2)
//   final String imageUrl;

//   @HiveField(3)
//   final num duration;

//   @HiveField(4)
//   final DateTime releaseDate;

//   @HiveField(5)
//   final bool isFavorite;

//   @HiveField(6)
//   final String songId;

//   @HiveField(7)
//   final String songUrl;

//   SongEntity({
//     required this.title,
//     required this.artist,
//     required this.imageUrl,
//     required this.duration,
//     required this.releaseDate,
//     required this.isFavorite,
//     required this.songId,
//     required this.songUrl,
//   });

//   // Factory to create from Firestore document
//   factory SongEntity.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;

//     Timestamp? timestamp = data['releaseDate'] as Timestamp?;

//     return SongEntity(
//       title: data['title'] ?? '',
//       artist: data['artist'] ?? '',
//       imageUrl: data['imageUrl'] ?? '',
//       duration: data['duration'] ?? 0,
//       releaseDate:
//           timestamp?.toDate() ??
//           DateTime.now(), // convert Timestamp -> DateTime
//       isFavorite: data['isFavorite'] ?? false,
//       songId : doc.id,
//       songUrl: data['songUrl'] ?? '',
//     );
//   }

  // ignore_for_file: public_member_api_docs, sort_constructors_first
  // import 'package:cloud_firestore/cloud_firestore.dart';

  // class SongEntity {
  //   final String title;
  //   final String artist;
  //   final String imageUrl;
  //   final num duration;
  //   final Timestamp releaseDate;
  //   final bool isFavorite;
  //   final String songId;
  //   final String songUrl;

  //   SongEntity({
  //     required this.title,
  //     required this.artist,
  //     required this.imageUrl,
  //     required this.duration,
  //     required this.releaseDate,
  //     required this.isFavorite,
  //     required this.songId,
  //     required this.songUrl,
  //   });
  // }

