// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/main.dart';

void main() {
  testWidgets('Next generates a new word', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(const MyApp());

    var wordPair = getDisplayedWordPair();

    // When
    await tester.tap(find.text('Next'));
    await tester.pump();

    // Then
    expect(getDisplayedWordPair(), isNot(wordPair));
  });
}

String getDisplayedWordPair() {
  return (find.byKey(const Key('wordPairDisplay')).evaluate().single.widget
          as Text)
      .data!;
}
