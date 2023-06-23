import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:phantom_solutions/core/data/model/todomodel.dart';
import 'package:phantom_solutions/view/home/home_bloc/home_bloc.dart';
import '../addtask/add_task.dart';
import '../detailedview/detailedview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<TodoModel> dataBox;
  @override
  void initState() {
    dataBox = Hive.box('todo');
    super.initState();
  }

  String formatted = DateFormat.yMMMd().format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final home = BlocProvider.of<HomeBloc>(context);

    return SafeArea(
      child: BlocBuilder<HomeBloc, HomeState>(
        bloc: home,
        builder: (context, state) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/Header-PhotoRoom.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: 222,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 25.0,
                                      left: 20,
                                    ),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: Theme.of(context).primaryColor,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 67,
                                  ),
                                  Column(
                                    children: [
                                      const SizedBox(
                                        height: 34,
                                      ),
                                      Text(
                                        formatted,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(
                                        height: 50,
                                      ),
                                      Text(
                                        'My Todo List',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width / 10,
                            top: MediaQuery.of(context).size.height / 4.8,
                          ),
                          child: Container(
                              width: MediaQuery.of(context).size.width / 1.24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  16,
                                ),
                              ),
                              child: state is HomeDataLoaded
                                  ? state.todouncompleted.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(30.0),
                                          child: Center(
                                            child: Text(
                                              'No tasks pending',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium!
                                                  .copyWith(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          itemBuilder: (ctx, index) {
                                            List<int> keyy =
                                                state.todouncompleted.toList();
                                            final key = keyy[index];

                                            final TodoModel? todos =
                                                dataBox.get(key);

                                            return ListTile(
                                              onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailedView(
                                                            todoModel: todos,
                                                            homeBloc: home,
                                                            modelKey: key,
                                                          ))),
                                              title: Text(
                                                todos!.taskName,
                                              ),
                                              subtitle: Text(
                                                todos.time ?? '',
                                              ),
                                              trailing: Checkbox(
                                                value: todos.isDone,
                                                onChanged: (value) {
                                                  todos.isDone = value!;
                                                  home.add(
                                                    UpdateData(
                                                        todoModel: todos,
                                                        box: dataBox,
                                                        key: key),
                                                  );
                                                  home.add(
                                                    LoadData(
                                                      box: dataBox,
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          separatorBuilder: (ctx, index) =>
                                              const Divider(),
                                          itemCount:
                                              state.todouncompleted.length,
                                          shrinkWrap: true,
                                        )
                                  : const SizedBox()),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Text(
                        'Completed',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            16,
                          ),
                        ),
                        child: state is HomeLoading
                            ? const CircularProgressIndicator()
                            : state is HomeDataLoaded
                                ? state.todocompleted.isEmpty &&
                                        state.todouncompleted.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Center(
                                            child: Text(
                                          'No tasks completed yet',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                        )),
                                      )
                                    : ListView.separated(
                                        itemBuilder: (ctx, index) {
                                          List<int> keyy =
                                              state.todocompleted.toList();
                                          final key = keyy[index];

                                          final TodoModel? todos =
                                              dataBox.get(key);
                                          return ListTile(
                                            title: Text(
                                              todos!.taskName,
                                              style: const TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  todos.time != '' &&
                                                          todos.date != ''
                                                      ? const Color(
                                                          0XFFE7E2F3,
                                                        )
                                                      : const Color(0XFFDBECF6),
                                              child: todos.time != '' &&
                                                      todos.date != ''
                                                  ? Image.asset(
                                                      'assets/images/calendar-event-fill.png',
                                                    )
                                                  : Image.asset(
                                                      'assets/images/file-list-line.png',
                                                    ),
                                            ),
                                            subtitle: Text(
                                              todos.time ?? '',
                                              style: const TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                            trailing: Checkbox(
                                              value: todos.isDone,
                                              onChanged: (value) {},
                                            ),
                                          );
                                        },
                                        separatorBuilder: (ctx, index) =>
                                            const Divider(),
                                        itemCount: state.todocompleted.length,
                                        shrinkWrap: true,
                                      )
                                : const SizedBox()),
                  ),
                  const SizedBox(
                    height: 80,
                  )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTask(
                      homeBloc: home,
                    ),
                  ),
                );
              },
              label: SizedBox(
                height: 56,
                width: 358,
                child: Center(
                  child: Text(
                    'Add New Task',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }
}
