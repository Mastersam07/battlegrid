import 'package:battlegrid/controller.dart';
import 'package:battlegrid/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChessGame', () {
    test('Infantry should move correctly', () {
      final game = ChessGame();
      final infantry = Infantry("white", CellPosition(6, 5));
      game.chessboard[6][5] = infantry;

      // Example: Infantry moves forward by 1 step
      expect(
          infantry.canMove(
              CellPosition(6, 5), CellPosition(5, 5), game.chessboard),
          isTrue);
    });
  });
}
