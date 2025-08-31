// home_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'violation_event.dart';
part 'violation_state.dart';

class ViolationBloc extends Bloc<ViolationEvent, ViolationState> {
  ViolationBloc()
      : super(const HomeLoaded(violations: {
          'speeding': false,
          'illegal-parking': false,
          'traffic-light': false,
          'reckless-driving': false,
          'phone-use': false,
          'no-seatbelt': false,
          'other': false,
        })) {
    on<UpdateViolationEvent>(_onUpdateViolation);
    on<ResetViolationsEvent>(_onResetViolations);
  }

  void _onUpdateViolation(UpdateViolationEvent event, Emitter<ViolationState> emit) {
    if (state is HomeLoaded) {
      final currentViolations = Map<String, bool>.from((state as HomeLoaded).violations);
      currentViolations[event.key] = event.value;
      emit(HomeLoaded(violations: currentViolations));
    }
  }

  void _onResetViolations(ResetViolationsEvent event, Emitter<ViolationState> emit) {
    if (state is HomeLoaded) {
      final currentViolations = (state as HomeLoaded).violations;
      final resetViolations =
          currentViolations.map((key, value) => MapEntry(key, false));
      emit(HomeLoaded(violations: resetViolations));
    }
  }
  
}