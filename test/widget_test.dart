import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crimson_map/main.dart';

void main() {
  testWidgets('CrimsonMapApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CrimsonMapApp()),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
