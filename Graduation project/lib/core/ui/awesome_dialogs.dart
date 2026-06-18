import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

void showNoConnectionDialog(BuildContext context,
    {String? title, String? desc}) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.error,
    animType: AnimType.scale,
    title: title ?? 'No Internet Connection',
    desc: desc ?? 'Please check your internet connection and try again.',
    btnOkOnPress: () {},
  ).show();
}

void showErrorDialog(BuildContext context,
    {required String title, required String description}) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.error,
    animType: AnimType.scale,
    title: title,
    desc: description,
    btnOkOnPress: () {},
  ).show();
}
