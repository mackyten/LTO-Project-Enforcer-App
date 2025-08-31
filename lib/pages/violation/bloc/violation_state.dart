// home_state.dart
part of 'violation_bloc.dart';

abstract class ViolationState extends Equatable {
  const ViolationState();

  @override
  List<Object> get props => [];
}

final class HomeInitial extends ViolationState {}

class HomeLoaded extends ViolationState {
  final Map<String, bool> violations;

  const HomeLoaded({required this.violations});

  @override
  List<Object> get props => [violations];
}