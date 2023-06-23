// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phantom_solutions/core/data/model/todomodel.dart';
import 'package:phantom_solutions/core/data/services/database_services.dart';
import 'package:phantom_solutions/core/data/services/notification_services.dart';

part 'addtask_event.dart';
part 'addtask_state.dart';

class AddtaskBloc extends Bloc<AddtaskEvent, AddtaskState> {
  AddtaskBloc() : super(AddtaskInitial()) {
    on<AddData>((event, emit) {
      emit(AddtaskLoading());
      try {
        DataBaseServices().addData(
          todoModel: event.todoModel,
          dataBox: event.box,
        );
        if (event.needReminder) {
          NotificationServices.showScheduledNotification(
            scheduledTime: event.dateTime!,
            body: event.notificationBody,
            title: event.notificationHeader,
          );
          emit(
            AddtaskSuccess(),
          );
        } else {
          emit(
            AddtaskSuccess(),
          );
        }
      } catch (e) {
        emit(
          AddtaskFailed(
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
