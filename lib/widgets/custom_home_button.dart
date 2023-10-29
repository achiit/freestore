// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:giga_share/resources/color_constants.dart';

class CustomHomeButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final IconData icon;
  final Color color;

  const CustomHomeButton({
    Key? key,
    required this.color,
    required this.icon,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 150,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                )
                /*gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),*/
                ),
            child: Center(
              child: Icon(
                icon,
                size: 50,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
