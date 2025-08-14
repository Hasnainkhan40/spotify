import 'package:equatable/equatable.dart';

abstract class StoreSongState extends Equatable {
  const StoreSongState();

  @override
  List<Object?> get props => [];
}

class StoreSongInitial extends StoreSongState {}

class StoreSongLoading extends StoreSongState {}

class StoreSongSuccess extends StoreSongState {}

class StoreSongFailure extends StoreSongState {
  final String message;
  const StoreSongFailure(this.message);

  @override
  List<Object?> get props => [message];
}
