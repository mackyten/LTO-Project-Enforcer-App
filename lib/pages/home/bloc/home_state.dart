part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final EnforcerModel enforcerData;
  final WeekleySummaryModel weeklySummary;

  const HomeLoaded({
    required this.enforcerData,
    required this.weeklySummary,
  });

  @override
  List<Object?> get props => [enforcerData, weeklySummary];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}