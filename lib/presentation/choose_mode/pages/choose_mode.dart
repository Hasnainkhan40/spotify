import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify/common/widgets/button/basic_app_button.dart';
import 'package:spotify/core/configs/assets/app_images.dart';
import 'package:spotify/core/configs/assets/app_vectors.dart';
import 'package:spotify/core/configs/theme/app_colors.dart';
import 'package:spotify/presentation/auth/pages/signup_or_siginin.dart';
import 'package:spotify/presentation/choose_mode/bloc/theme_cubit.dart';

class ChooseModePage extends StatefulWidget {
  const ChooseModePage({super.key});

  @override
  State<ChooseModePage> createState() => _ChooseModePageState();
}

class _ChooseModePageState extends State<ChooseModePage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _darkModeController;
  late AnimationController _lightModeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  ThemeMode? _selectedMode;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _darkModeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _lightModeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _isInitialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    _darkModeController.dispose();
    _lightModeController.dispose();
    super.dispose();
  }

  void _selectDarkMode() {
    setState(() {
      _selectedMode = ThemeMode.dark;
    });
    _darkModeController.forward().then((_) {
      _darkModeController.reverse();
    });
    context.read<ThemeCubit>().updateTheme(ThemeMode.dark);
  }

  void _selectLightMode() {
    setState(() {
      _selectedMode = ThemeMode.light;
    });
    _lightModeController.forward().then((_) {
      _lightModeController.reverse();
    });
    context.read<ThemeCubit>().updateTheme(ThemeMode.light);
  }

  Widget _buildModeButton({
    required String icon,
    required String label,
    required ThemeMode mode,
    required VoidCallback onTap,
    required AnimationController controller,
  }) {
    final isSelected = _selectedMode == mode;

    return Column(
      children: [
        AnimatedScale(
          scale: controller.isAnimating ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary.withOpacity(0.7)
                              : const Color(0xff30393c).withOpacity(0.5),
                      shape: BoxShape.circle,
                      border:
                          isSelected
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                    ),
                    child: SvgPicture.asset(icon, fit: BoxFit.none),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 17,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.grey,
          ),
          child: Text(label),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(AppImages.chooseModeBG),
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.15)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            child: Column(
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SvgPicture.asset(AppVectors.logo),
                  ),
                ),
                const Spacer(),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'Choose Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 21),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildModeButton(
                              icon: AppVectors.moon,
                              label: 'Dark Mode',
                              mode: ThemeMode.dark,
                              onTap: _selectDarkMode,
                              controller: _darkModeController,
                            ),
                            const SizedBox(width: 40),
                            _buildModeButton(
                              icon: AppVectors.sun,
                              label: 'Light Mode',
                              mode: ThemeMode.light,
                              onTap: _selectLightMode,
                              controller: _lightModeController,
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        BasicAppButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (BuildContext context) =>
                                        const SignupOrSigninPage(),
                              ),
                            );
                          },
                          title: 'Continue',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
