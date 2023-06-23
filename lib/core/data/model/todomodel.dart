import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';

part 'todomodel.g.dart';

@HiveType(typeId: 2)
class TodoModel {
  @HiveField(0)
  String taskName;
  @HiveField(1)
  String? date;
  @HiveField(2)
  String? time;
  @HiveField(3)
  String? notes;
  @HiveField(4)
  Uint8List? imageUint8List;
  @HiveField(5)
  bool isDone;

  TodoModel({
    required this.taskName,
    required this.isDone,
    this.time,
    this.date,
    this.notes,
    this.imageUint8List,
  });
}
