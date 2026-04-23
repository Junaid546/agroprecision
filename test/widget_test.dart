import 'package:flutter_test/flutter_test.dart';
import 'package:agro_precision/app.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AgroPrecisionApp());

    // Verify that the initial text is shown.
    expect(find.text('AgroPrecision Initialized'), findsOneWidget);
  });
}
