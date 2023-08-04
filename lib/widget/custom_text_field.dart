import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {Key? key, required this.name, required this.controller})
      : super(key: key);

  final String name;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.blueGrey.withOpacity(0.2),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: name,
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
