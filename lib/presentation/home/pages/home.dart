// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:hive/hive.dart';
// import 'package:spotify/domain/entities/song/song_entity.dart';
// import 'package:spotify/presentation/favoritesongs/favaritessong.dart';
// import 'package:spotify/presentation/home/pages/homescreen.dart';
// import 'package:spotify/presentation/profile/pages/profile.dart';
// import 'package:spotify/presentation/song_player/pages/song_player.dart';
// import 'package:spotify/presentation/searchScreen/pages/searchScreen.dart';

// import '../../../common/widgets/appbar/app_bar.dart';
// import '../../../core/configs/assets/app_vectors.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   int _selectedIndex = 0;
//   late List<Widget> _pages;

//   final List<IconData> _icons = [
//     Icons.home_rounded,
//     Icons.play_arrow_rounded,
//     Icons.favorite_sharp,
//     Icons.person_outline,
//   ];

//   final List<String> _labels = ['Home', 'Play', 'Favorite', 'Profile'];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     final lastSong = Hive.box<SongEntity>('last_song').get('current');

//     _pages = [
//       const HomePage(),
//       SongPlayerPage(
//         songEntity:
//             lastSong ??
//             SongEntity(
//               title: 'Default Song',
//               artist: 'Unknown Artist',
//               imageUrl: '',
//               duration: 0,
//               songUrl: '',
//               isFavorite: false,
//               releaseDate: DateTime.now(),
//               songId: '',
//             ),
//       ),
//       const Favaritessong(),
//       const ProfilePage(),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Container(
//           height: 70,
//           decoration: BoxDecoration(
//             color: const Color(0xFF1C1C1E),
//             borderRadius: BorderRadius.circular(50),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: List.generate(_icons.length, (index) {
//               final bool isSelected = _selectedIndex == index;
//               return GestureDetector(
//                 onTap: () => _onItemTapped(index),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 10,
//                   ),
//                   decoration: BoxDecoration(
//                     color:
//                         isSelected
//                             ? const Color(0xff42C83C)
//                             : Colors.transparent,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         _icons[index],
//                         color: isSelected ? Colors.white : Colors.grey[400],
//                       ),
//                       if (isSelected) ...[
//                         const SizedBox(width: 8),
//                         Text(
//                           _labels[index],
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//       appBar:
//           _selectedIndex == 0
//               ? BasicAppbar(
//                 hideBack: true,
//                 action: IconButton(
//                   icon: const Icon(Icons.search_rounded, color: Colors.green),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (BuildContext context) => const SearchPage(),
//                       ),
//                     );
//                   },
//                 ),
//                 title: SvgPicture.asset(AppVectors.logo, height: 40, width: 40),
//               )
//               : null,
//       body: _pages[_selectedIndex],
//     );
//   }
// }
