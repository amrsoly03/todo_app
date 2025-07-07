import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme.dart';

class MyButton extends StatelessWidget {
  const MyButton({Key? key, required this.label, required this.onTap})
      : super(key: key);

  final String label;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(label, style: supTitleStyle.copyWith(color: white)),
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(context.theme.primaryColor),
        minimumSize: MaterialStatePropertyAll(Size(100, 45)),
        shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }
}
