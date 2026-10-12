import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_app/main.dart';

void main() {
  testWidgets('TOEIC App initializes smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ToeicApp());
    expect(find.byType(ToeicApp), findsOneWidget);
  });
}
