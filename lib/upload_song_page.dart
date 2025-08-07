// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;

// class UploadSongPage extends StatefulWidget {
//   @override
//   _UploadSongPageState createState() => _UploadSongPageState();
// }

// class _UploadSongPageState extends State<UploadSongPage> {
//   String? uploadedUrl;

//   Future<void> uploadSongToCloudinary() async {
//     final cloudName = 'dmsal1h1j'; // ✅ your Cloudinary cloud name
//     final uploadPreset = 'songs_flutter'; // ✅ your unsigned preset name

//     // Step 1: Pick a file
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['mp3', 'wav'],
//     );

//     if (result != null && result.files.single.path != null) {
//       File file = File(result.files.single.path!);
//       String fileName = path.basename(file.path);

//       // Step 2: Create upload request
//       var uri = Uri.parse(
//         "https://api.cloudinary.com/v1_1/$cloudName/video/upload",
//       );

//       var request =
//           http.MultipartRequest('POST', uri)
//             ..fields['upload_preset'] = uploadPreset
//             ..fields['folder'] =
//                 'songs' // optional: Cloudinary folder
//             ..files.add(await http.MultipartFile.fromPath('file', file.path));

//       // Step 3: Send the request
//       var response = await request.send();

//       if (response.statusCode == 200) {
//         final respStr = await response.stream.bytesToString();
//         final data = json.decode(respStr);
//         setState(() {
//           uploadedUrl = data['secure_url'];
//         });
//         print("✅ Uploaded successfully: $uploadedUrl");
//       } else {
//         print("❌ Upload failed: ${response.statusCode}");
//       }
//     } else {
//       print("❗ File pick cancelled");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Upload Song to Cloudinary")),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: uploadSongToCloudinary,
//                 child: Text("Pick & Upload Song"),
//               ),
//               SizedBox(height: 20),
//               if (uploadedUrl != null) ...[
//                 Text(
//                   "Uploaded URL:",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 SelectableText(
//                   uploadedUrl!,
//                   style: TextStyle(color: Colors.blue),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
