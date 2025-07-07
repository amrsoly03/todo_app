import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/controllers/task_controller.dart';
import 'package:todo/models/task.dart';
import 'package:todo/ui/widgets/appbar.dart';
import 'package:todo/ui/widgets/button.dart';

import '../../services/theme_services.dart';
import '../theme.dart';
import '../widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String _endtTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(minutes: 15)))
      .toString();

  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];

  String _selectedRepeat = 'None';
  List<String> repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];

  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyAppBar(
                title: 'Add Task',
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_ios),
                ),
              ),
              InputField(
                label: 'Title',
                hint: 'enter title here',
                controller: _titleController,
              ),
              const SizedBox(height: 20),
              InputField(
                label: 'Note',
                hint: 'enter note here',
                controller: _noteController,
              ),
              const SizedBox(height: 20),
              InputField(
                label: 'Date',
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () => _getDate(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      label: 'Start Time',
                      hint: _startTime,
                      widget: IconButton(
                        icon: const Icon(Icons.access_time_outlined),
                        onPressed: () => getTime(isStartTime: true),
                      ),
                    ),
                  ),
                  //SizedBox(width: ),
                  Expanded(
                    child: InputField(
                      label: 'End Time',
                      hint: _endtTime,
                      widget: IconButton(
                        icon: const Icon(Icons.access_time_outlined),
                        onPressed: () => getTime(isStartTime: false),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InputField(
                label: 'Remind',
                hint: '$_selectedRemind minutes early',
                widget: DropDown(
                  remindList,
                  (String? newVal) {
                    setState(() {
                      _selectedRemind = int.parse(newVal!);
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              InputField(
                label: 'Repeat',
                hint: _selectedRepeat,
                widget: DropDown(
                  repeatList,
                  (String? newVal) {
                    setState(() {
                      _selectedRepeat = newVal!;
                    });
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    coloredCircles(),
                    const Spacer(),
                    MyButton(
                        label: 'Add Task',
                        onTap: () {
                          return _validate();
                        }),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Column coloredCircles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color', style: titleStyle),
        const SizedBox(height: 5),
        Wrap(
          children: List.generate(
              3,
              (index) => GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: index == 0
                            ? primaryClr
                            : index == 1
                                ? orangeClr
                                : pinkClr,
                        child: _selectedColor == index
                            ? const Icon(Icons.done, size: 15, color: white)
                            : null,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedColor = index;
                      });
                    },
                  )),
        )
      ],
    );
  }

  _validate() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToDb();
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar(
        'Required',
        'all fields are required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black54,
        colorText: white,
        icon: const Icon(Icons.warning_amber_outlined, color: Colors.amber),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
      );
    } else {
      log('..........something went wrong..........');
    }
  }

  _addTaskToDb() async {
    int value = await _taskController.addTask(
        task: Task(
      title: _titleController.text,
      note: _noteController.text,
      isCompleted: 0,
      color: _selectedColor,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      date: DateFormat.yMd().format(_selectedDate),
      startTime: _startTime,
      endTime: _endtTime,
    ));
    log('$value');
  }

  DropdownButton<String> DropDown(List list, Function(String?) onChanged) {
    return DropdownButton(
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Colors.grey,
      ),
      elevation: 4,
      iconSize: 30,
      underline: Container(height: 0),
      items: list
          .map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(
                value: value.toString(),
                child: Text('$value'),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  _getDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    } else {
      log('something wrong in date');
    }
  }

  getTime({required bool isStartTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(DateTime.now())
          : TimeOfDay.fromDateTime(
              DateTime.now().add(const Duration(minutes: 15))),
    );
    String formattedTime = pickedTime!.format(context);

    if (isStartTime) {
      setState(() => _startTime = formattedTime);
    } else if (!isStartTime) {
      setState(() => _endtTime = formattedTime);
    } else {
      log('something wrong in date');
    }
  }
}
