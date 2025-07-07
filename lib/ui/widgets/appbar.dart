import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar(
      {Key? key, required this.title, required this.leading, this.action})
      : super(key: key);

  final String title;
  final Widget leading;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: context.theme.colorScheme.background,
      centerTitle: true,
      elevation: 0,
      actions: [
        action != null ? action! : Container(),
        const CircleAvatar(
          backgroundImage: AssetImage('images/person.jpeg'),
        ),
        const SizedBox(width: 10),
      ],
      leading: leading,
    );
  }
}
