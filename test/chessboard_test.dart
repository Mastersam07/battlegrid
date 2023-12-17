import 'package:battlegrid/chessboard.dart';
import 'package:battlegrid/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChessboardGrid displays correct number of cells',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MyHomePage()));

    expect(find.byType(ChessboardGrid), findsOneWidget);

    // Find the GridView within ChessboardGrid
    final Finder gridViewFinder = find.descendant(
      of: find.byType(ChessboardGrid),
      matching: find.byType(GridView),
    );

    // Count the number of GestureDetector widgets within the GridView
    final int gestureDetectorCount = tester
        .widgetList(find.descendant(
          of: gridViewFinder,
          matching: find.byType(GestureDetector),
        ))
        .length;

    expect(gestureDetectorCount,
        121); // Expecting 121 gesture detectors for 11x11 grid
  });
}
