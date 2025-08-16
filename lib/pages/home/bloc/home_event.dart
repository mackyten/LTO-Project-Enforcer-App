// home_event.dart
part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class UpdateViolationEvent extends HomeEvent {
  final String key;
  final bool value;

  const UpdateViolationEvent({required this.key, required this.value});

  @override
  List<Object> get props => [key, value];
}

class ResetViolationsEvent extends HomeEvent {}