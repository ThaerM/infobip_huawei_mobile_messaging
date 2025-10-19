import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_huawei_mobile_messaging_example/main.dart';

void main() {
  testWidgets('App builds without exceptions', (WidgetTester tester) async {
    // Build the example app
    await tester.pumpWidget(const App());

    // Verify that a Scaffold is present (app rendered)
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
