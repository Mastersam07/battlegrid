import 'piece.dart';

class Move {
  String fromCellId;
  String toCellId;
  Piece movedPiece;
  Piece? capturedPiece;

  Move(this.fromCellId, this.toCellId, this.movedPiece, this.capturedPiece);
}
