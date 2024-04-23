import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opstracker/compliance/time_report/models/defaulters_model.dart';
import 'package:opstracker/compliance/time_report/services/defaulters_service.dart';

// Events
abstract class DefaultersEvent {}

class FetchDefaultersEvent extends DefaultersEvent {
  final String startDate;
  final String endDate;
  final int buId;

  FetchDefaultersEvent({
    required this.startDate,
    required this.endDate,
    required this.buId,
  });
}

// States
abstract class DefaultersState {}

class DefaultersLoadingState extends DefaultersState {}

class DefaultersLoadedState extends DefaultersState {
  final List<Defaulter> defaulters;

  DefaultersLoadedState({required this.defaulters});
}

class DefaultersErrorState extends DefaultersState {
  final String errorMessage;

  DefaultersErrorState({required this.errorMessage});
}

// Bloc
class DefaultersBloc extends Bloc<DefaultersEvent, DefaultersState> {
  final DefaultersService _defaultersService = DefaultersService();

  DefaultersBloc() : super(DefaultersLoadingState()) {
    on<FetchDefaultersEvent>((event, emit) async {
      emit(DefaultersLoadingState());
      try {
        final Map<String, Map<String, dynamic>> missedDatesMap =
            await _defaultersService.fetchDefaulters(
          startDate: event.startDate,
          endDate: event.endDate,
          buId: event.buId,
        );

        // Construct list of Defaulter objects from missedDatesMap
        final List<Defaulter> defaulters = missedDatesMap.entries.map((entry) {
          return Defaulter(
            name: entry.key,
            empId: entry.value['empId'] ?? '', // Extract empId from map
            missedDates: (entry.value['missedDates'] as List<DateTime>?) ?? [],
          );
        }).toList();

        emit(DefaultersLoadedState(defaulters: defaulters));
      } catch (e) {
        emit(DefaultersErrorState(errorMessage: e.toString()));
      }
    });
  }
}
