import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify/data/models/song/song.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';
import 'package:spotify/domain/usecases/song/is_favorite_song.dart';
import 'package:spotify/domain/usecases/song/is_favorite_song.dart';

import '../../../service_locator.dart';

abstract class SongFirebaseService {
  Future<Either> getNewsSongs();
  Future<Either> getPlayList();
  Future<Either> addOrRemoveFavoriteSong(String songId);
  Future<bool> isFavoriteSong(String songId);
  Future<Either> getUserFavoriteSongs();
  Future<Either<String, void>> storeSong(SongEntity song);
  Future<Either<String, List<SongEntity>>> searchSongs(String query);
}

class SongFirebaseServiceImpl extends SongFirebaseService {
  @override
  Future<Either<String, List<SongEntity>>> getNewsSongs() async {
    try {
      List<SongEntity> songs = [];

      var data =
          await FirebaseFirestore.instance
              .collection('songs')
              .orderBy('releaseDate', descending: true)
              .limit(6)
              .get();

      for (var element in data.docs) {
        print("Raw data: ${element.data()}");

        var songModel = SongModel.fromJson(element.data());

        print("Parsed image URL: ${songModel.imageUrl}");

        bool isFavorite = await sl<IsFavoriteSongUseCase>().call(
          params: element.reference.id,
        );

        songModel.isFavorite = isFavorite;
        songModel.songId = element.reference.id;

        songs.add(songModel.toEntity());
      }

      print('Returning ${songs.length} songs');
      return Right(songs);
    } catch (e) {
      print('Error in getNewsSongs(): $e');
      return const Left('An error occurred, Please try again.');
    }
  }

  @override
  Future<Either<String, void>> storeSong(SongEntity song) async {
    try {
      final model = SongModel.fromEntity(song);

      final docRef = await FirebaseFirestore.instance
          .collection('songs')
          .add(model.toJson());

      await docRef.update({'songId': docRef.id});

      return const Right(null);
    } catch (e) {
      return Left('Error storing song: $e');
    }
  }

  @override
  Future<Either> getPlayList() async {
    try {
      List<SongEntity> songs = [];
      var data =
          await FirebaseFirestore.instance
              .collection('songs')
              .orderBy('releaseDate', descending: true)
              .get();

      for (var element in data.docs) {
        var songModel = SongModel.fromJson(element.data());
        bool isFavorite = await sl<IsFavoriteSongUseCase>().call(
          params: element.reference.id,
        );
        songModel.isFavorite = isFavorite;
        songModel.songId = element.reference.id;
        songs.add(songModel.toEntity());
      }

      return Right(songs);
    } catch (e) {
      print(e);
      return const Left('An error occurred, Please try again.');
    }
  }

  @override
  Future<Either> addOrRemoveFavoriteSong(String songId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      final user = firebaseAuth.currentUser;
      if (user == null) {
        print("⚠️ addOrRemoveFavoriteSong: No logged-in user found");
        return const Left("User not logged in");
      }

      final String uId = user.uid;

      QuerySnapshot favoriteSongs =
          await firebaseFirestore
              .collection('Users')
              .doc(uId)
              .collection('Favorites')
              .where('songId', isEqualTo: songId)
              .get();

      bool isFavorite;
      if (favoriteSongs.docs.isNotEmpty) {
        await favoriteSongs.docs.first.reference.delete();
        isFavorite = false;
      } else {
        await firebaseFirestore
            .collection('Users')
            .doc(uId)
            .collection('Favorites')
            .add({'songId': songId, 'addedDate': Timestamp.now()});
        isFavorite = true;
      }

      return Right(isFavorite);
    } catch (e) {
      print("Error in addOrRemoveFavoriteSong(): $e");
      return const Left('An error occurred');
    }
  }

  @override
  Future<bool> isFavoriteSong(String songId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("⚠️ isFavoriteSong: No user logged in");
        return false;
      }

      final firebaseFirestore = FirebaseFirestore.instance;
      String uId = user.uid;

      QuerySnapshot favoriteSongs =
          await firebaseFirestore
              .collection('Users')
              .doc(uId)
              .collection('Favorites')
              .where('songId', isEqualTo: songId)
              .get();

      return favoriteSongs.docs.isNotEmpty;
    } catch (e) {
      print("Error in isFavoriteSong(): $e");
      return false;
    }
  }

  @override
  Future<Either> getUserFavoriteSongs() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("⚠️ getUserFavoriteSongs: No logged-in user found");
        return const Left("User not logged in");
      }

      final firebaseFirestore = FirebaseFirestore.instance;
      List<SongEntity> favoriteSongs = [];
      String uId = user.uid;

      QuerySnapshot favoritesSnapshot =
          await firebaseFirestore
              .collection('Users')
              .doc(uId)
              .collection('Favorites')
              .get();

      for (var element in favoritesSnapshot.docs) {
        String songId = element['songId'];
        var song =
            await firebaseFirestore.collection('songs').doc(songId).get();

        if (!song.exists) continue;

        SongModel songModel = SongModel.fromJson(song.data()!);
        songModel.isFavorite = true;
        songModel.songId = songId;
        favoriteSongs.add(songModel.toEntity());
      }

      return Right(favoriteSongs);
    } catch (e) {
      print("Error in getUserFavoriteSongs(): $e");
      return const Left('An error occurred');
    }
  }

  //search
  @override
  Future<Either<String, List<SongEntity>>> searchSongs(String query) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]); // return empty list for empty query
      }

      // Normalize query for case-insensitive search
      String normalizedQuery = query.toLowerCase();

      final songsCollection = FirebaseFirestore.instance.collection('songs');

      // 🔎 Fetch all songs once
      final snapshot =
          await songsCollection
              .where('title', isGreaterThanOrEqualTo: normalizedQuery)
              .where('title', isLessThanOrEqualTo: '$normalizedQuery\uf8ff')
              .get();

      // Filter songs first
      List<SongModel> matchedSongs = [];
      for (var doc in snapshot.docs) {
        final songModel = SongModel.fromJson(doc.data());
        songModel.songId = doc.id;

        if (songModel.title?.toLowerCase().contains(normalizedQuery) == true ||
            songModel.artist?.toLowerCase().contains(normalizedQuery) == true) {
          matchedSongs.add(songModel);
        }
      }

      // ✅ Run favorite checks in parallel using Future.wait
      final results = await Future.wait(
        matchedSongs.map((songModel) async {
          bool isFavorite = await sl<IsFavoriteSongUseCase>().call(
            params: songModel.songId,
          );
          songModel.isFavorite = isFavorite;
          return songModel.toEntity();
        }),
      );

      return Right(results);
    } catch (e) {
      print("Error in searchSongs(): $e");
      return Left("Error while searching songs: $e");
    }
  }
}
