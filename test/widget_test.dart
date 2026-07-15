import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:makeni_prayer_book/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MakeniPrayerBookApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
