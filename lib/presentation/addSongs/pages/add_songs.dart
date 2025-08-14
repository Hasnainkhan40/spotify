import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
import 'package:spotify/common/widgets/appbar/app_bar.dart';
import 'package:spotify/core/configs/assets/app_vectors.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';
import 'package:spotify/presentation/addSongs/bloc/addsong_bloc.dart';
import 'package:spotify/presentation/addSongs/bloc/addsong_event.dart';
import 'package:spotify/presentation/addSongs/bloc/addsong_state.dart';
import 'package:uuid/uuid.dart';

class AddSongs extends StatefulWidget {
  const AddSongs({super.key});

  @override
  State<AddSongs> createState() => _AddSongsState();
}

class _AddSongsState extends State<AddSongs> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController artistController = TextEditingController();
  final TextEditingController releaseDateController = TextEditingController();

  File? _selectedImage;
  String? _selectedSongPath;
  num? _calculatedDuration;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    titleController.dispose();
    artistController.dispose();
    releaseDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickSongFile() async {
    final songFile = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (songFile != null && songFile.files.single.path != null) {
      _selectedSongPath = songFile.files.single.path!;

      final player = AudioPlayer();
      await player.setFilePath(_selectedSongPath!);

      // Get duration
      final durationInSeconds = player.duration?.inSeconds ?? 0;
      _calculatedDuration = durationInSeconds;

      setState(() {});
    }
  }

  void _saveSong() {
    final title = titleController.text.trim();
    final artist = artistController.text.trim();
    final releaseDateText = releaseDateController.text.trim();

    if (title.isEmpty ||
        artist.isEmpty ||
        _selectedSongPath == null ||
        releaseDateText.isEmpty ||
        _calculatedDuration == null) {
      showDialog(
        context: context,
        builder:
            (_) => const AlertDialog(
              content: Text(
                "Please fill all the fields and select a song file",
              ),
            ),
      );
      return;
    }

    DateTime parsedReleaseDate;
    try {
      parsedReleaseDate = DateTime.parse(releaseDateText);
    } catch (_) {
      parsedReleaseDate = DateTime.now();
    }

    final song = SongEntity(
      title: title,
      artist: artist,
      imageUrl: _selectedImage?.path ?? '',
      duration: _calculatedDuration!,
      releaseDate: parsedReleaseDate,
      isFavorite: false,
      songId: const Uuid().v4(),
      songUrl: '', // Upload later
    );

    context.read<StoreSongBloc>().add(StoreSongRequested(song));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreSongBloc, StoreSongState>(
      listener: (context, state) {
        if (state is StoreSongLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is StoreSongSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Song added successfully")),
          );
        } else if (state is StoreSongFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: Scaffold(
        backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
        appBar: BasicAppbar(
          hideBack: true,
          title: SvgPicture.asset(AppVectors.logo, height: 40, width: 40),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Add new song",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff42C83C),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    "Please enter your song details",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),

                // Song Cover
                const Center(
                  child: Text(
                    "Song cover",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 55),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color:
                              context.isDarkMode ? Colors.white : Colors.black,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child:
                          _selectedImage == null
                              ? const Center(
                                child: Icon(
                                  Icons.add_circle_outlined,
                                  color: Colors.white38,
                                  size: 40,
                                ),
                              )
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Song Title
                const Text(
                  "Song title",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Enter..",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Artist
                const Text(
                  "Artist",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: artistController,
                  decoration: InputDecoration(
                    hintText: "Enter..",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Release Date
                const Text(
                  "Release Date",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: releaseDateController,
                  decoration: InputDecoration(
                    hintText: "YYYY-MM-DD",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Song File
                ElevatedButton(
                  onPressed: _pickSongFile,
                  child: const Text(
                    "Select Song File",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                if (_calculatedDuration != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Duration: $_calculatedDuration sec",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 24),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveSong,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          context.isDarkMode
                              ? const Color(0xff42C83C)
                              : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Add song",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
