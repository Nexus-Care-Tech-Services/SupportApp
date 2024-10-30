import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:support/utils/color.dart';

void toastshowDefaultSnackbar(
    BuildContext context, content, bool islong, Color color) {
  Fluttertoast.showToast(
      msg: content,
      toastLength: islong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: color,
      textColor: colorWhite,
      fontSize: 14.0);
}
