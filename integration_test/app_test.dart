// On-device version of the end-to-end workflow and widget checks.
//
// Run on a connected Android device or emulator:
//   flutter test integration_test/app_test.dart
import 'package:integration_test/integration_test.dart';

import '../test/widget/app_widget_test.dart' as widgets;
import '../test/workflow/full_workflow_test.dart' as workflow;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  workflow.main();
  widgets.main();
}
