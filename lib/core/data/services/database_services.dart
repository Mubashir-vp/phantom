import 'dart:developer';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phantom_solutions/core/data/model/todomodel.dart';

class DataBaseServices {
  addData({
    required TodoModel todoModel,
    required Box<TodoModel> dataBox,
  }) {
    dataBox.add(todoModel);
  }

  updateData(
      {required Box<TodoModel> dataBox,
      required TodoModel todoModel,
      required int key}) {
    try {
      dataBox.put(key, todoModel);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<File> getImageFromHive({required List<int> bytes}) async {
    final String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath =
        '${(await getApplicationDocumentsDirectory()).path}/$imageName.jpg';
    final File imageFile = File(filePath);
    await imageFile.writeAsBytes(bytes);
    return imageFile;
  }
}
