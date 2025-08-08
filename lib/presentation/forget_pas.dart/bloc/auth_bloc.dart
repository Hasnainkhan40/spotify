import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/domain/usecases/auth/update_pass.dart';
import 'package:spotify/presentation/forget_pas.dart/bloc/auth_event.dart';
import 'package:spotify/presentation/forget_pas.dart/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthBloc({required this.resetPasswordUseCase}) : super(AuthInitial()) {
    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());

      final result = await resetPasswordUseCase(event.email);

      result.fold(
        (failure) => emit(AuthFailure(failure)),
        (message) => emit(PasswordResetSuccess(message)),
      );
    });
  }
}
