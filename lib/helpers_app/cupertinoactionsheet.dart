import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Cupertinoactionsheet extends StatefulWidget {
  const Cupertinoactionsheet({super.key});

  @override
  State<Cupertinoactionsheet> createState() => _CupertinoactionsheetState();
}

class _CupertinoactionsheetState extends State<Cupertinoactionsheet> {
  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text('Choose Profile Photo'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Camera',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Gallery',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          'Cancel',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
