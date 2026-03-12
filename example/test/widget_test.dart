import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AudioKitExampleApp());
    expect(find.text('AudioKit Example'), findsOneWidget);
    expect(find.text('Initialize Engine'), findsOneWidget);
  });
}
