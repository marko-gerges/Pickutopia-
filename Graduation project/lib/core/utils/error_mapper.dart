String friendlyErrorMessage(Object? error) {
  final s = error is String
      ? error
      : (error?.toString() ?? 'An unknown error occurred.');
  final lower = s.toLowerCase();

  // Network/connectivity related
  if (lower.contains('connection refused') ||
      lower.contains('failed host lookup') ||
      lower.contains('socketexception') ||
      lower.contains('network') ||
      lower.contains('failed to connect') ||
      lower.contains('timed out') ||
      lower.contains('timeout') ||
      lower.contains('internet')) {
    return 'Network connection problem. Please check your internet and try again.';
  }

  // Common auth errors
  if (lower.contains('wrong password') ||
      lower.contains('invalid password') ||
      lower.contains('invalid credentials') ||
      lower.contains('invalid login') ||
      lower.contains('wrong email') ||
      lower.contains('user not found') ||
      lower.contains('no user') ||
      lower.contains('no user logged in')) {
    return 'Incorrect email or password. Please check your credentials.';
  }

  if (lower.contains('email already') ||
      lower.contains('already exists') ||
      lower.contains('duplicate')) {
    return 'An account with that email already exists.';
  }

  if (lower.contains('unauthorized') ||
      lower.contains('forbidden') ||
      lower.contains('unauthenticated')) {
    return 'You are not authorized. Please sign in again.';
  }

  if (lower.contains('upload') ||
      lower.contains('storage') ||
      lower.contains('file')) {
    return 'Failed to upload the file. Please try again.';
  }

  // Generic fallback: strip common exception prefixes and return first line
  final cleaned = s.replaceAll(RegExp(r'^[\w\.]*Exception:?\s*'), '');
  final firstLine = cleaned.split('\n').first.trim();
  if (firstLine.isEmpty) return 'An unknown error occurred.';
  return firstLine.length > 120
      ? '${firstLine.substring(0, 117)}...'
      : firstLine;
}
