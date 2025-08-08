import 'package:dartz/dartz.dart';
import 'package:spotify/domain/repository/auth/auth.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<String, String>> call(String email) {
    return repository.resetPassword(email);
  }
}
