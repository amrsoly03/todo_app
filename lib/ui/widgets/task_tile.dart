import 'package:flutter/material.dart';
import 'package:todo/models/task.dart';
import 'package:todo/ui/theme.dart';

import '../size_config.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({Key? key, required this.task}) : super(key: key);

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(
              SizeConfig.orientation == Orientation.landscape ? 4 : 15)),
      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(12)),
      width: SizeConfig.orientation == Orientation.landscape
          ? SizeConfig.screenWidth / 2
          : SizeConfig.screenWidth,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _getClr(task.color),
        ),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title!,
                    style: supTitleStyle.copyWith(
                      color: white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 20, color: white),
                      const SizedBox(width: 8),
                      Text(
                        '${task.startTime} - ${task.endTime}',
                        style: bodyStyle.copyWith(
                          color: white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    task.note!,
                    style: bodyStyle.copyWith(
                      color: white,
                    ),
                  ),
                ],
              ),
            )),
            Container(
              width: 1,
              height: 75,
              color: white,
            ),
            const SizedBox(width: 10),
            RotatedBox(
              quarterTurns: 3,
              child: Text(
                task.isCompleted == 1 ? 'Completed' : 'TODO',
                style: bodyStyle.copyWith(
                  color: white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getClr(int? color) {
    switch (color) {
      case 0:
        return bluishClr;

      case 1:
        return orangeClr;

      case 2:
        return pinkClr;

      default:
        return bluishClr;
    }
  }
}
