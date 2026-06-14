import 'dart:async';

/// Global test setup. Currently a pass-through; golden tests are tagged
/// `golden` and excluded from the default run.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await testMain();
}
