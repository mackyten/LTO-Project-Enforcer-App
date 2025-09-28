part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final DriverModel? driverData;
  final EnforcerModel? enforcerData;
  final WeekleySummaryModel weeklySummary;

  const HomeLoaded({
    this.driverData,
    this.enforcerData,
    required this.weeklySummary,
  });

  @override
  List<Object?> get props => [driverData, enforcerData, weeklySummary];

  // Helper methods to check user type
  bool get isDriver => driverData != null;
  bool get isEnforcer => enforcerData != null && !isDriver;
  
  // Get the current user data (driver takes precedence)
  UserModelWithRoles.UserModel? get userData => driverData ?? enforcerData;
  
  // Safe helper methods with null checking
  bool get isAdmin => userData?.roles?.contains(UserRoles.Admin) ?? false;
  List<UserRoles> get userRoles => userData?.roles ?? [];
  String get fullName {
    final user = userData;
    if (user != null) {
      return '${user.firstName} ${user.lastName}';
    }
    return 'Unknown User';
  }
  String get profilePictureUrl => userData?.profilePictureUrl ?? '';

  // Driver-specific helper methods
  String? get driverPlateNumber => driverData?.plateNumber;
  String? get driverLicenseNumber => driverData?.driverLicenseNumber;
  bool get hasDriverData => driverData != null && driverData!.plateNumber != null;

  // Safe casting methods (now much simpler)
  DriverModel? get asDriver => driverData;
  EnforcerModel? get asEnforcer => enforcerData;

  // Validation methods
  bool get isValid => isDriver || isEnforcer;
  String get userType => isDriver ? 'Driver' : (isEnforcer ? 'Enforcer' : 'Unknown');
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}