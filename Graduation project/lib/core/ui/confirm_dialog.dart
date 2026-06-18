import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

/// Shows a confirmation dialog using AwesomeDialog and returns true when
/// the user confirms, false when they cancel.
Future<bool> showConfirmDialog(
  BuildContext context, {
  String title = 'Confirm',
  String desc = '',
  DialogType dialogType = DialogType.question,
  bool dismissOnTouchOutside = false,
}) {
  final completer = Completer<bool>();

  AwesomeDialog(
    context: context,
    dialogType: dialogType,
    animType: AnimType.scale,
    title: title,
    desc: desc,
    dismissOnTouchOutside: dismissOnTouchOutside,
    btnCancelOnPress: () {
      if (!completer.isCompleted) completer.complete(false);
    },
    btnOkOnPress: () {
      if (!completer.isCompleted) completer.complete(true);
    },
  ).show();

  return completer.future;
}
