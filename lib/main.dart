import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phantom_solutions/core/data/model/todomodel.dart';
import 'package:phantom_solutions/view/home/home_bloc/home_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/data/services/notification_services.dart';
import 'core/foundation/app_theme.dart';
import 'view/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationServices().initNotification();
  tz.initializeTimeZones();
  Directory path = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(path.path);
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox<TodoModel>('todo');
  runApp(BlocProvider(
    create: (context) {
      return HomeBloc()
        ..add(
          LoadData(
            box: Hive.box('todo'),
          ),
        );
    },
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const HomeScreen());
  }
}
