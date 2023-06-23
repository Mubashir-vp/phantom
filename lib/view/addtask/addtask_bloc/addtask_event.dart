part of 'addtask_bloc.dart';

abstract class AddtaskEvent extends Equatable {
  const AddtaskEvent();

  @override
  List<Object> get props => [];
}

class AddData extends AddtaskEvent {
  final TodoModel todoModel;
  final bool needReminder;
  final DateTime? dateTime;
  final String? notificationBody;
  final String? notificationHeader;
  final Box<TodoModel> box;
  const AddData({
    required this.todoModel,
    required this.box,
    required this.needReminder,
    this.notificationBody,
    this.notificationHeader,
    this.dateTime,
  });
  @override
  List<Object> get props => [
        todoModel,
        box,
      ];
}
