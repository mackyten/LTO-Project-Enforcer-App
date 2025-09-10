import 'package:enforcer_auto_fine/pages/home/components/weekly_summary.dart';
import 'package:enforcer_auto_fine/pages/home/handlers.dart';
import 'package:enforcer_auto_fine/pages/home/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:enforcer_auto_fine/shared/models/enforcer_model.dart';

import '../../violation/models/report_model.dart';


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
      // Fetch enforcer data
      final enforcerResponse = await _handlers.fetchUserData();
      final weeklySummary = await _handlers.getWeeklySummary();
      if (!enforcerResponse.success || enforcerResponse.data == null) {
        emit(HomeError(message: enforcerResponse.message!));
        return;
      }
      final UserModel enforcerData = enforcerResponse.data!;

      // Fetch violation reports
      // (You need to create a service for this similar to fetchUserData)
     // final reports = await fetchReports();
      
      emit(HomeLoaded(
        enforcerData: enforcerData,
        weeklySummary: weeklySummary,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}