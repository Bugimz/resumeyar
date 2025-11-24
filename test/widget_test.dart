import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resumeyar/main.dart';

void main() {
  testWidgets('Home page renders welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome to ResumeYar!'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
