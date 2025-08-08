import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/helpers/is_dark_mode.dart';
import 'package:spotify/common/widgets/appbar/app_bar.dart';
import 'package:spotify/presentation/forget_pas.dart/bloc/auth_bloc.dart';
import 'package:spotify/presentation/forget_pas.dart/bloc/auth_event.dart';
import 'package:spotify/presentation/forget_pas.dart/bloc/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // Future<void> passwordReset() async {
  //   final email = emailController.text.trim();
  //   if (email.isEmpty) {
  //     showDialog(
  //       context: context,
  //       builder:
  //           (_) => const AlertDialog(
  //             content: Text("Please enter your email address."),
  //           ),
  //     );
  //     return;
  //   }

  //   try {
  //     await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  //     showDialog(
  //       context: context,
  //       builder:
  //           (_) => const AlertDialog(
  //             content: Text("Password reset link sent! Check your email."),
  //           ),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     showDialog(
  //       context: context,
  //       builder:
  //           (_) => AlertDialog(
  //             content: Text(e.message ?? "Something went wrong."),
  //           ),
  //     );
  //   }
  // }
  // UI → BLoC → UseCase → AuthRepositoryImpl → AuthFirebaseServiceImpl → Firebase

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetSuccess) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(content: Text(state.message)),
          );
        } else if (state is AuthFailure) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
        appBar: BasicAppbar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Forgot password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff42C83C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please enter your email to reset the password",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text(
                "Your Email",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "your@email.com",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      showDialog(
                        context: context,
                        builder:
                            (_) => const AlertDialog(
                              content: Text("Please enter your email address."),
                            ),
                      );
                    } else {
                      context.read<AuthBloc>().add(
                        ResetPasswordRequested(email),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        context.isDarkMode
                            ? const Color(0xff42C83C)
                            : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Reset Password",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
