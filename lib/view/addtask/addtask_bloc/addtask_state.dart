part of 'addtask_bloc.dart';

abstract class AddtaskState extends Equatable {
  const AddtaskState();

  @override
  List<Object> get props => [];
}

class AddtaskInitial extends AddtaskState {}

class AddtaskLoading extends AddtaskState {}

class AddtaskSuccess extends AddtaskState {}

class AddtaskFailed extends AddtaskState {
  final String errorMessage;
  const AddtaskFailed({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}
