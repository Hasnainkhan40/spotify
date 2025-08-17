import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

final cloudinary = CloudinaryPublic(
  'dmsal1h1j', // e.g., 'mycloudname'
  'songs_flutter', // e.g., 'ml_default'
  cache: false,
);

Future<String> uploadFileToCloudinary(File file, String folder) async {
  try {
    CloudinaryResponse response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(file.path, folder: folder),
    );
    return response.secureUrl; // URL to store in Firestore
  } catch (e) {
    throw Exception("Cloudinary upload failed: $e");
  }
}
