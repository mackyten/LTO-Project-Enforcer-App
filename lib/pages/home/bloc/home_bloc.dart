import 'package:enforcer_auto_fine/pages/home/handlers.dart';
import 'package:enforcer_auto_fine/pages/home/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:enforcer_auto_fine/shared/models/user_model.dart' as UserModelWithRoles;
import 'package:enforcer_auto_fine/shared/models/driver_model.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_model.dart';
import 'package:enforcer_auto_fine/enums/user_roles.dart';


part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {

  final _handlers = HomeHandlers();

  HomeBloc() : super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
  }

  Future<void> _onFetchHomeData(
      FetchHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      // Fetch typed user data
      final userResponse = await _handlers.fetchTypedUserData();
      final weeklySummary = await _handlers.getWeeklySummary();
      
      if (!userResponse.success || userResponse.data == null) {
        emit(HomeError(message: userResponse.message!));
        return;
      }
      
      final userData = userResponse.data!;
      final roles = userData.roles;
      
      // Determine user type and populate appropriate properties
      DriverModel? driverData;
      EnforcerModel? enforcerData;
      
      if (roles!.length == 2 && 
          roles.contains(UserRoles.Driver) && 
          roles.contains(UserRoles.None)) {
        // User is a driver
        driverData = userData is DriverModel ? userData : null;
        // If somehow we didn't get a DriverModel, try to create one from the data
        if (driverData == null) {
          driverData = DriverModel.fromJson(userData.toJson());
        }
      } else if (roles.length == 2 && 
                 roles.contains(UserRoles.Enforcer) && 
                 roles.contains(UserRoles.None)) {
        // User is an enforcer
        enforcerData = userData is EnforcerModel ? userData : EnforcerModel.fromJson(userData.toJson());
      } else {
        // Handle other role combinations (admin, etc.) - default to enforcer for now
        enforcerData = userData is EnforcerModel ? userData : EnforcerModel.fromJson(userData.toJson());
      }
      
      emit(HomeLoaded(
        driverData: driverData,
        enforcerData: enforcerData,
        weeklySummary: weeklySummary,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}