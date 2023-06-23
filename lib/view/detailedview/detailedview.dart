import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:phantom_solutions/core/data/model/todomodel.dart';
import 'package:phantom_solutions/core/data/services/database_services.dart';
import 'package:phantom_solutions/view/addtask/addtask_bloc/addtask_bloc.dart';

import '../home/home_bloc/home_bloc.dart';

class DetailedView extends StatefulWidget {
  const DetailedView(
      {super.key,
      required this.todoModel,
      required this.homeBloc,
      required this.modelKey});
  final TodoModel todoModel;
  final HomeBloc homeBloc;
  final int modelKey;

  @override
  State<DetailedView> createState() => _DetailedViewState();
}

class _DetailedViewState extends State<DetailedView> {
  File? image;
  String? selectedDate;
  bool isEdit = false;
  TimeOfDay selectedTime = TimeOfDay.now();
  late final Box<TodoModel> dataBox;
  TextEditingController datecontroller = TextEditingController();
  TextEditingController taskcontroller = TextEditingController();
  TextEditingController notescontroller = TextEditingController();
  TextEditingController timecontroller = TextEditingController();
  final AddtaskBloc _addtaskBloc = AddtaskBloc();

  final _formKey = GlobalKey<FormState>();
  Future<void> _getImageFromGallery() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        image = File(result.files.single.path!);
      });
    }
  }

  setData() async {
    taskcontroller.text = widget.todoModel.taskName;
    datecontroller.text = widget.todoModel.date ?? '';
    timecontroller.text = widget.todoModel.time ?? '';
    notescontroller.text = widget.todoModel.notes ?? '';
    image = await DataBaseServices().getImageFromHive(
      bytes: widget.todoModel.imageUint8List!.toList(),
    );
    setState(() {});
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedS =
        await showTimePicker(context: context, initialTime: selectedTime);

    if (pickedS != null && pickedS != selectedTime) {
      setState(() {
        DateTime now = DateTime.now();
        DateTime dateTime = DateTime(
            now.year, now.month, now.day, pickedS.hour, pickedS.minute);

        String formattedTime = DateFormat('hh:mm a').format(dateTime);
        timecontroller.text = formattedTime;
      });
    } else {
      DateTime now = DateTime.now();
      DateTime dateTime = DateTime(
          now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
      String formattedTime = DateFormat('hh:mm a').format(dateTime);

      timecontroller.text = formattedTime;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        datecontroller.text = DateFormat.yMMMd().format(pickedDate);
      });
    }
  }

  @override
  void initState() {
    dataBox = Hive.box('todo');
    setData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      bloc: widget.homeBloc,
      listener: (context, state) {
        if (state is HomeUpdatedSuccess) {
          taskcontroller.clear();
          notescontroller.clear();
          datecontroller.clear();
          timecontroller.clear();
          image = null;
          setState(() {});
          Fluttertoast.showToast(
              msg: 'Task Updated Successfully',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.pop(context);
          widget.homeBloc.add(
            LoadData(
              box: Hive.box('todo'),
            ),
          );
        }
      },
      child: Scaffold(
        floatingActionButton: Visibility(
          visible: isEdit,
          child: FloatingActionButton.extended(
            onPressed: () async {
              if (image == null) {
                Fluttertoast.showToast(
                    msg: 'Please select a image',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    fontSize: 16.0);
              } else if (_formKey.currentState!.validate()) {
                List<int> imageBytes = await image!.readAsBytes();
                Uint8List imageUint8List = Uint8List.fromList(imageBytes);
                widget.homeBloc.add(
                  UpdateData(
                      key: widget.modelKey,
                      todoModel: TodoModel(
                        isDone: false,
                        taskName: taskcontroller.text,
                        notes: notescontroller.text,
                        date: datecontroller.text,
                        time: timecontroller.text,
                        imageUint8List: imageUint8List,
                      ),
                      box: dataBox),
                );
              } else {
                log('Else called');
              }
            },
            label: SizedBox(
              height: 56,
              width: 358,
              child: Center(
                child: _addtaskBloc.state is AddtaskLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        'Save ',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white),
                      ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
          title: Text(
            'Task',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
          ),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                  size: 15,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                isEdit = !isEdit;
                setState(() {});
              },
              icon: Icon(
                isEdit ? Icons.save : Icons.edit,
              ),
            ),
            IconButton(
              onPressed: () {
                dataBox.delete(
                  widget.modelKey,
                );
                taskcontroller.clear();
                notescontroller.clear();
                datecontroller.clear();
                timecontroller.clear();
                image = null;
                setState(() {});
                Fluttertoast.showToast(
                    msg: 'Task deleted successfully',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    fontSize: 16.0);
                Navigator.pop(context);
                widget.homeBloc.add(
                  LoadData(
                    box: Hive.box('todo'),
                  ),
                );
              },
              icon: const Icon(
                Icons.delete,
              ),
            )
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      'assets/images/appbar.png',
                    ),
                    fit: BoxFit.fill)),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 24.0,
                  left: 24,
                ),
                child: Text(
                  'Task Title',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 15.0,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty || value == '') {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                  controller: taskcontroller,
                  enabled: isEdit,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Task Title',
                  ),
                ),
              ),
              image == null
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                      ),
                      child: Text(
                        'Add Image',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                          ),
                          child: Text(
                            'Add Image',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 14.0),
                          child: IconButton(
                            onPressed: () {
                              isEdit ? _getImageFromGallery() : null;
                            },
                            icon: const Icon(
                              Icons.change_circle,
                            ),
                          ),
                        )
                      ],
                    ),
              image == null
                  ? Padding(
                      padding: const EdgeInsets.only(
                        top: 15.0,
                        left: 24,
                        right: 24,
                        bottom: 24,
                      ),
                      child: TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          suffixIcon: Image.asset(
                            'assets/images/Camera frame.png',
                          ),
                          hintText: 'Add Image',
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(
                        23.0,
                      ),
                      child: SizedBox(
                        height: 205,
                        width: 400,
                        child: Image.file(
                          image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                          ),
                          child: Text(
                            'Date',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 15.0,
                            left: 24,
                            right: 24,
                            bottom: 24,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              isEdit ? _selectDate(context) : null;
                            },
                            child: TextFormField(
                              controller: datecontroller,
                              enabled: false,
                              decoration: InputDecoration(
                                suffixIcon: Icon(Icons.calendar_month,
                                    color: isEdit
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey),
                                border: const OutlineInputBorder(),
                                hintText: 'Date',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                          ),
                          child: Text(
                            'Time',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 15.0,
                            left: 24,
                            right: 24,
                            bottom: 24,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              isEdit ? _selectTime(context) : null;
                            },
                            child: TextFormField(
                              enabled: false,
                              controller: timecontroller,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                suffixIcon: Icon(Icons.access_time,
                                    color: isEdit
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey),
                                hintText: 'Time',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 24.0,
                  left: 24,
                ),
                child: Text(
                  'Notes',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 15.0,
                  left: 24,
                  right: 24,
                ),
                child: TextFormField(
                  enabled: isEdit,
                  controller: notescontroller,
                  minLines: 5,
                  maxLines: 9,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Notes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
