part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeFailed extends HomeState {
  final String errorMessage;
  const HomeFailed({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

class HomeUpdatedSuccess extends HomeState {
  const HomeUpdatedSuccess();
  @override
  List<Object> get props => [];
}

class HomeDataLoaded extends HomeState {
  final List<int> todouncompleted;
  final List<int> todocompleted;

  const HomeDataLoaded(
      {required this.todocompleted, required this.todouncompleted});
  @override
  List<Object> get props => [
        todocompleted,
        todouncompleted,
      ];
}
