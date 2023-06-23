import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phantom_solutions/core/data/model/todomodel.dart';

import '../../../core/data/services/database_services.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadData>((event, emit) {
      emit(HomeLoading());
      try {
        List<int> incompleted = event.box.keys
            .cast<int>()
            .where((key) => event.box.get(key)!.isDone == false)
            .toList();
        List<int> completed = event.box.keys
            .cast<int>()
            .where((key) => event.box.get(key)!.isDone == true)
            .toList();
        emit(
          HomeDataLoaded(
              todocompleted: completed, todouncompleted: incompleted),
        );
      } catch (e) {
        emit(
          HomeFailed(
            errorMessage: e.toString(),
          ),
        );
      }
    });
    on<UpdateData>((event, emit) {
      emit(HomeLoading());
      try {
        DataBaseServices().updateData(
          todoModel: event.todoModel,
          dataBox: event.box,
          key: event.key,
        );

        emit(
          const HomeUpdatedSuccess(),
        );
      } catch (e) {
        emit(
          HomeFailed(
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
