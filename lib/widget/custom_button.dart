import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({Key? key, required this.name, required this.onPressed})
      : super(key: key);

  final String name;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
            child: CupertinoButton(
              onPressed: onPressed,
              color: Theme.of(context).primaryColor,
              child: Text(name),
            ),
          ),
        ),
      ],
    );
  }
}
