part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadData extends HomeEvent {
  final Box<TodoModel> box;
  const LoadData({
    required this.box,
  });
  @override
  List<Object> get props => [
        box,
      ];
}

class UpdateData extends HomeEvent {
  final Box<TodoModel> box;
  final TodoModel todoModel;
  final int key;
  const UpdateData({
    required this.todoModel,
    required this.box,
    required this.key,
  });
  @override
  List<Object> get props => [box, todoModel, key];
}
