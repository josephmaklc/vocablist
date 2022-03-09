
import 'package:flutter/material.dart';

Future<bool> areYouSureDialog(BuildContext context,String title,String message) async {
  // set up the buttons
  bool result = false;
  Widget yesButton = TextButton(
    child: Text("Yes"),
    onPressed: () {
      result = true;
      Navigator.pop(context, 'Yes');
    },
  );
  Widget noButton = TextButton(
    child: Text("No"),
    onPressed: () {
      result = false;
      Navigator.pop(context, 'No');
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      yesButton,
      noButton,
    ],
  );
/*  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );

 */
  await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return alert;
        });
      }
  );

  return result;
}