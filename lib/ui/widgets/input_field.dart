import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme.dart';

class InputField extends StatelessWidget {
  InputField({
    Key? key,
    required this.label,
    required this.hint,
    this.widget,
    this.controller,
  }) : super(key: key);

  final String label;
  final String hint;
  final Widget? widget;

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: titleStyle,
          ),
          const SizedBox(height: 5),
          TextFormField(
            autofocus: false,
            controller: controller,
            readOnly: widget != null ? true : false,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: supTitleStyle,
              suffixIcon: widget,
              fillColor: Get.isDarkMode
                  ? darkHeaderClr.withOpacity(0.3)
                  : const Color.fromARGB(255, 231, 231, 231),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(width: 5, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
