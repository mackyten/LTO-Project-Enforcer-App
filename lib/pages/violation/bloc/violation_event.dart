// home_event.dart
part of 'violation_bloc.dart';

abstract class ViolationEvent extends Equatable {
  const ViolationEvent();

  @override
  List<Object> get props => [];
}

class UpdateViolationEvent extends ViolationEvent {
  final String key;
  final dynamic value; // Changed to dynamic to support both bool and custom data

  const UpdateViolationEvent({required this.key, required this.value});

  @override
  List<Object> get props => [key, value];
}

class ResetViolationsEvent extends ViolationEvent {}