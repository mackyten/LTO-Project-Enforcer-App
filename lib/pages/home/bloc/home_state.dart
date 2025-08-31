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
  final List<ReportModel> reports;

  const HomeLoaded({
    required this.enforcerData,
    required this.reports,
  });

  @override
  List<Object?> get props => [enforcerData, reports];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}