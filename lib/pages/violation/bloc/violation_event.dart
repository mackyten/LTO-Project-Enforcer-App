// home_event.dart
part of 'violation_bloc.dart';

abstract class ViolationEvent extends Equatable {
  const ViolationEvent();

  @override
  List<Object> get props => [];
}

class UpdateViolationEvent extends ViolationEvent {
  final String key;
  final bool value;

  const UpdateViolationEvent({required this.key, required this.value});

  @override
  List<Object> get props => [key, value];
}

class ResetViolationsEvent extends ViolationEvent {}