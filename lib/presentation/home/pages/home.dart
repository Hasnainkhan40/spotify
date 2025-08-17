import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
import 'package:spotify/core/configs/assets/app_images.dart';
import 'package:spotify/core/configs/theme/app_colors.dart';
import 'package:spotify/domain/entities/song/song_entity.dart';
import 'package:spotify/presentation/favoritesongs/favaritessong.dart';
import 'package:spotify/presentation/home/widgets/news_songs.dart';
import 'package:spotify/presentation/home/widgets/play_list.dart';
import 'package:spotify/presentation/profile/pages/profile.dart';
import 'package:spotify/presentation/song_player/pages/song_player.dart';
import 'package:spotify/presentation/searchScreen/pages/searchScreen.dart';
// import 'package:spotify/presentation/profile/pages/profile.dart';

import '../../../common/widgets/appbar/app_bar.dart';
import '../../../core/configs/assets/app_vectors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  late final SongEntity songEntity;
  late List<Widget> _pages;

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.play_arrow_rounded,
    Icons.favorite_sharp,
    Icons.person_outline,
  ];

  final List<String> _labels = ['Home', 'play', 'Favorite', 'Profile'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final lastSong = Hive.box<SongEntity>('last_song').get('current');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    final lastSong = Hive.box<SongEntity>('last_song').get('current');

    _pages = [
      HomePage(),
      SongPlayerPage(
        songEntity:
            lastSong ??
            SongEntity(
              title: 'Default Song',
              artist: 'Unknown Artist',
              imageUrl: '',
              duration: 0,
              songUrl: '',
              isFavorite: false,
              releaseDate: DateTime.now(),
              songId: '',
            ),
      ),
      const Favaritessong(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (index) {
              final bool isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => _onItemTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xff42C83C)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _icons[index],
                        color: isSelected ? Colors.white : Colors.grey[400],
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          _labels[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      appBar:
          _selectedIndex == 0
              ? BasicAppbar(
                hideBack: true,
                action: IconButton(
                  icon: const Icon(Icons.search_rounded, color: Colors.green),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const SearchPage(),
                      ),
                    );
                  },
                ),
                title: SvgPicture.asset(AppVectors.logo, height: 40, width: 40),
              )
              : null,
      body:
          _selectedIndex == 0
              ? SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    _homeTopCard(),
                    SizedBox(height: 40),
                    _tabs(),
                    SizedBox(height: 25),
                    Divider(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          NewsSongs(),
                          Center(child: Text("Videos")),
                          Center(child: Text("Artists")),
                          Center(child: Text("Podcasts")),
                        ],
                      ),
                    ),
                    const PlayList(),
                  ],
                ),
              )
              : _pages[_selectedIndex],
    );
  }

  Widget _homeTopCard() {
    return Center(
      child: SizedBox(
        height: 140,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(AppVectors.homeTopCard),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 60),
                child: Image.asset(AppImages.homeArtist),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.center,
      labelColor: context.isDarkMode ? Colors.white : Colors.black,
      indicatorColor: AppColors.primary,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      tabs: const [
        Text(
          'News',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        Text(
          'Videos',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        Text(
          'Artists',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        Text(
          'Podcasts',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
      ],
    );
  }

  // Widget _tabs() {
  //   return TabBar(
  //     controller: _tabController,
  //     isScrollable: true,
  //     labelColor: context.isDarkMode ? Colors.white : Colors.black,
  //     indicatorColor: AppColors.primary,
  //     padding: const EdgeInsets.symmetric(vertical: 40),
  //     tabs: const [
  //       Text(
  //         'News',
  //         style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
  //       ),
  //       Text(
  //         'Videos',
  //         style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
  //       ),
  //       Text(
  //         'Artists',
  //         style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
  //       ),
  //       Text(
  //         'Podcasts',
  //         style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
  //       ),
  //     ],
  //   );
  // }
}
