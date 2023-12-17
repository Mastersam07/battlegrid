import 'package:battlegrid/controller.dart';
import 'package:flutter/material.dart';

import 'models/models.dart';

class ChessboardGrid extends StatefulWidget {
  final ChessGame chessGame;

  const ChessboardGrid(this.chessGame, {super.key});

  @override
  State<ChessboardGrid> createState() => _ChessboardGridState();
}

class _ChessboardGridState extends State<ChessboardGrid> {
  Piece? selectedPiece;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 410,
      width: 410,
      margin: const EdgeInsets.all(10.0),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black, width: 8)),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 11,
          childAspectRatio: 1.0,
        ),
        itemCount: 121,
        itemBuilder: (BuildContext context, int index) {
          final row = index ~/ 11;
          final col = index % 11;
          final piece = widget.chessGame.getPieceAt(row, col);
          final isSelected = piece == selectedPiece;

          if (row == 5 && col == 5) {
            // Check if it's the center cell
            return GestureDetector(
              onTap: () {
                if (selectedPiece == null) return;
                final newPosition = CellPosition(row, col);
                if (selectedPiece!.canMove(selectedPiece!.position, newPosition,
                    widget.chessGame.chessboard)) {
                  // Move the piece
                  widget.chessGame.movePiece(selectedPiece!, newPosition);
                  setState(() {
                    selectedPiece = null;
                    widget.chessGame.selectedCell = null;
                  });
                }
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green[700],
                child: const CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.white,
                ),
              ),
            );
          }
          if (piece != null) {
            return GestureDetector(
              onTap: () {
                // Handle piece selection/deselection here
                if (selectedPiece == null) {
                  // If no piece is selected, select this piece
                  setState(() {
                    selectedPiece = piece;
                    widget.chessGame.selectedCell = CellPosition(row, col);
                  });
                } else if (selectedPiece == piece) {
                  // If the same piece is tapped again, deselect it
                  setState(() {
                    selectedPiece = null;
                    widget.chessGame.selectedCell = null;
                  });
                }
              },
              child: Container(
                alignment: Alignment.center,
                color: isSelected
                    ? Colors.yellow
                    : (index % 2 == 0)
                        ? Colors.green[700]
                        : Colors.white,
                child: Text(
                  piece.icon,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.black
                        : (index % 2 == 0)
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              ),
            );
          } else {
            return GestureDetector(
              onTap: () {
                if (selectedPiece == null) return;
                final newPosition = CellPosition(row, col);
                if (selectedPiece!.canMove(selectedPiece!.position, newPosition,
                    widget.chessGame.chessboard)) {
                  // Move the piece
                  widget.chessGame.movePiece(selectedPiece!, newPosition);
                  setState(() {
                    selectedPiece = null;
                    widget.chessGame.selectedCell = null;
                  });
                }
              },
              child: Container(
                alignment: Alignment.center,
                color: (index % 2 == 0) ? Colors.green[700] : Colors.white,
              ),
            );
          }
        },
      ),
    );
  }
}
