// home_state.dart
part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

final class HomeInitial extends HomeState {}

class HomeLoaded extends HomeState {
  final Map<String, bool> violations;

  const HomeLoaded({required this.violations});

  @override
  List<Object> get props => [violations];
}