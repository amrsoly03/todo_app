import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/models/task.dart';
import 'package:todo/services/notification_services.dart';
import 'package:todo/services/theme_services.dart';
import 'package:todo/ui/pages/add_task_page.dart';
import 'package:todo/ui/size_config.dart';
import 'package:todo/ui/theme.dart';
import 'package:todo/ui/widgets/appbar.dart';
import 'package:todo/ui/widgets/button.dart';
import 'package:todo/ui/widgets/task_tile.dart';

import '../../controllers/task_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotifyHelper notifyHelper;
  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIosPemissions();
    _taskController.getTask();
  }

  final TaskController _taskController = Get.put(TaskController());
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            MyAppBar(
              title: 'Home',
              leading: IconButton(
                onPressed: () {
                  ThemeServices().switchTheme();

                  NotifyHelper().displayNotification(
                    title: 'Theme Changed',
                    body: 'body',
                  );

                  //NotifyHelper().scheduledNotification();
                },
                icon: Icon(
                  Get.isDarkMode
                      ? Icons.wb_sunny_outlined
                      : Icons.nightlight_round_outlined,
                  color: Get.isDarkMode ? white : darkGreyClr,
                  size: 25,
                ),
              ),
              action: IconButton(
                onPressed: () {
                  _taskController.deleteAllTask();
                  NotifyHelper().cancelAllNotification();
                },
                icon: Icon(
                  Icons.delete_sweep_outlined,
                  color: Get.isDarkMode ? white : darkGreyClr,
                  size: 30,
                ),
              ),
            ),
            _addTaskBar(),
            const SizedBox(height: 10),
            _addDateBar(),
            const SizedBox(height: 10),
            _showTasks(),
          ],
        ),
      ),
    );
  }

  _addTaskBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()).toString(),
                style: supHeadingStyle,
              ),
              Text('Today', style: headingStyle),
            ],
          ),
          MyButton(
              label: '+ Add Task',
              onTap: () async {
                await Get.to(() => const AddTaskPage());
                _taskController.getTask();
              }),
        ],
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(left: 15, top: 5),
      child: SingleChildScrollView(
        child: DatePicker(
          DateTime.now(),
          initialSelectedDate: DateTime.now(),
          height: 100,
          width: 70,
          selectionColor: primaryClr,
          dayTextStyle: supTitleStyle.copyWith(color: Colors.grey),
          monthTextStyle: supTitleStyle.copyWith(color: Colors.grey),
          dateTextStyle: supTitleStyle.copyWith(color: Colors.grey),
          onDateChange: (newDate) {
            setState(() {
              _selectedDate = newDate;
            });
          },
        ),
      ),
    );
  }

  _showTasks() {
    return Expanded(
      child: Obx(
        () {
          if (_taskController.taskList.isEmpty) {
            return _noTaskMsg();
          } else {
            return ListView.builder(
              scrollDirection:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? Axis.horizontal
                      : Axis.vertical,
              itemCount: _taskController.taskList.length,
              itemBuilder: (BuildContext context, int index) {
                var task = _taskController.taskList[index];

                if (task.repeat == 'Daily' ||
                    task.date == DateFormat.yMd().format(_selectedDate) ||
                    (task.repeat == 'Weekly' &&
                        _selectedDate
                                    .difference(
                                        DateFormat.yMd().parse(task.date!))
                                    .inDays %
                                7 ==
                            0) ||
                    (task.repeat == 'Monthly' &&
                        DateFormat.yMd().parse(task.date!).day ==
                            _selectedDate.day)) {
                  //var date = DateFormat.jm().parse(task.startTime!);
                  //var myTime = DateFormat('HH:mm').format(date);
                  //('.....$hour : $minutes  ');

                  var hour = task.startTime.toString().split(':')[0];
                  var minutes =
                      task.startTime.toString().split(':')[1].numericOnly();

                  notifyHelper.scheduledNotification(
                    int.parse(hour),
                    int.parse(minutes),
                    task,
                  );
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 1000),
                    child: SlideAnimation(
                      horizontalOffset: 300,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () => _showBottomSheet(context, task),
                          child: TaskTile(task: task),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            );
          }
        },
      ),
    );
  }

  _noTaskMsg() {
    SizeConfig().init(context);
    return Stack(
      children: [
        SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: SizeConfig.orientation == Orientation.landscape
                ? Axis.horizontal
                : Axis.vertical,
            children: [
              SizeConfig.orientation == Orientation.landscape
                  ? const SizedBox(height: 5)
                  : const SizedBox(height: 200),
              SvgPicture.asset(
                'images/task.svg',
                height: 100,
                width: 100,
                color: primaryClr.withOpacity(0.5),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  'you don\'t have any tasks yet \nadd new tasks to make your days more productive',
                  style: supTitleStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  _buildBottomSheet({
    required String label,
    required Function() onTap,
    required Color clr,
    bool isClose = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        height: 75,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose ? Colors.grey[500]! : clr,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style: isClose
                ? titleStyle
                : titleStyle.copyWith(
                    color: white,
                  ),
          ),
        ),
      ),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 5),
        width: SizeConfig.screenWidth,
        height: SizeConfig.orientation == Orientation.landscape
            ? (task.isCompleted == 1
                ? SizeConfig.screenHeight * 0.6
                : SizeConfig.screenHeight * 0.8)
            : (task.isCompleted == 1
                ? SizeConfig.screenHeight * 0.3
                : SizeConfig.screenHeight * 0.4),
        color: Get.isDarkMode ? darkGreyClr : white,
        child: Column(
          children: [
            Flexible(
              child: Container(
                width: 120,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[450],
                ),
              ),
            ),
            const SizedBox(height: 10),
            task.isCompleted == 1
                ? Container()
                : _buildBottomSheet(
                    label: 'Task Completed',
                    onTap: () {
                      _taskController.markTaskCompleted(task.id!);
                      NotifyHelper().cancelNotification(task);
                      Get.back();
                    },
                    clr: primaryClr,
                  ),
            const SizedBox(height: 10),
            _buildBottomSheet(
              label: 'Delete Task',
              onTap: () {
                _taskController.deleteTask(task);
                NotifyHelper().cancelNotification(task);
                Get.back();
              },
              clr: Colors.red[900]!,
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.grey),
            _buildBottomSheet(
              label: 'Cancel',
              onTap: () => Get.back(),
              clr: primaryClr,
            ),
          ],
        ),
      ),
    ));
  }
}
