abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class PasswordResetSuccess extends AuthState {
  final String message;
  PasswordResetSuccess(this.message);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
