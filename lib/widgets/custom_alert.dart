import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final Widget content;

  void Function()? onpressed;

  CustomAlertDialog(
      {required this.title, required this.content, required this.onpressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 15),
              content,
              SizedBox(height: 22),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Ok",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    TextButton(
                      onPressed: onpressed,
                      child: Text(
                        "Show",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
