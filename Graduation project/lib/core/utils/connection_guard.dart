import 'package:flutter/material.dart';
import 'package:pickutopia/core/services/connectivity_service.dart';
import 'package:pickutopia/core/ui/awesome_dialogs.dart';
import 'package:pickutopia/core/utils/error_mapper.dart';

/// Runs [action] only if internet connection is available.
/// If no connection, shows an AwesomeDialog informing the user.
Future<T?> runWithConnection<T>(
    BuildContext context, Future<T> Function() action) async {
  final ok = await ConnectivityService().checkConnection();
  if (!ok) {
    if (context.mounted) showNoConnectionDialog(context);
    return null;
  }

  try {
    return await action();
  } catch (e) {
    // Show a friendly dialog for unexpected failures (network/server)
    final message = friendlyErrorMessage(e);
    if (context.mounted) {
      showErrorDialog(context, title: 'Operation failed', description: message);
    }
    return null;
  }
}
