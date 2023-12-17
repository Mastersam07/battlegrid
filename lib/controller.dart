import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/models.dart';

class ChessGame extends ChangeNotifier {
  // A 2D list representing the chessboard and the pieces on it
  final List<List<Piece?>> chessboard =
      List.generate(11, (_) => List.filled(11, null));

  final List<String> whitePiecesOrder = [
    "♙",
    "♖",
    "♘",
    "◎",
    "♗",
    "♕",
    "♔",
    "♕",
    "♗",
    "◎",
    "♘",
    "♖"
  ];
  final List<String> blackPiecesOrder = [
    "♟",
    "♜",
    "♞",
    "◉",
    "♝",
    "♛",
    "♚",
    "♛",
    "♝",
    "◉",
    "♞",
    "♜"
  ];

  late String lastMovedPiece;
  late List<Move> moveHistory;
  CellPosition? selectedCell;

  ChessGame() {
    lastMovedPiece = "black";
    moveHistory = [];
    selectedCell = null;
    initializeBoard();
  }

  void resetGameState() {
    moveHistory = [];
    selectedCell = null;
    lastMovedPiece = "black";
    initializeBoard();
  }

  void undoMove() {
    Move lastMove = moveHistory.removeLast();
    // Move the piece back to the original position
    final CellPosition fromPosition =
        _getCellPositionFromId(lastMove.fromCellId);
    final CellPosition toPosition = _getCellPositionFromId(lastMove.toCellId);
    final Piece movedPiece = lastMove.movedPiece;

    chessboard[fromPosition.row][fromPosition.col] = movedPiece;
    chessboard[toPosition.row][toPosition.col] = lastMove.capturedPiece;

    // Switch player's turn
    lastMovedPiece = (lastMovedPiece == "white") ? "black" : "white";

    // Notify listeners to update the UI
    notifyListeners();
  }

  void exportMoves() {
    if (moveHistory.isEmpty) return;

    List<String> moveStrings = [];
    for (Move move in moveHistory) {
      String fromCellId = move.fromCellId;
      String toCellId = move.toCellId;
      String movedPiece = move.movedPiece.icon;
      String capturedPiece = move.capturedPiece != null
          ? " capturing ${move.capturedPiece!.icon}"
          : "";
      moveStrings
          .add("$movedPiece from $fromCellId to $toCellId$capturedPiece");
    }

    var moves = moveStrings.join(";");

    Clipboard.setData(ClipboardData(text: moves));
  }

  void importMoves(String importString) {
    if (importString.trim().isEmpty) return;

    resetGameState();

    List<String> moveStrings = importString.split(";");
    for (var moveString in moveStrings) {
      if (moveString.trim().isEmpty) continue;

      List<String> moveParts = moveString.split(" ");
      String fromCellId = moveParts[2];
      String toCellId = moveParts[4];
      bool captured = moveString.contains("capturing");

      // Find the corresponding cells in the chessboard
      CellPosition fromPosition = _getCellPositionFromId(fromCellId);
      CellPosition toPosition = _getCellPositionFromId(toCellId);

      // Get the moved piece
      Piece? movedChessPiece = getPieceAt(fromPosition.row, fromPosition.col);

      if (movedChessPiece == null) {
        // Invalid move, no piece to move
        continue;
      }

      // Capture logic
      Piece? capturedPiece =
          captured ? getPieceAt(toPosition.row, toPosition.col) : null;

      // Move the piece to the new cell
      chessboard[toPosition.row][toPosition.col] = movedChessPiece;
      chessboard[fromPosition.row][fromPosition.col] = null;

      // Update the move history
      moveHistory.add(Move(
        fromCellId,
        toCellId,
        movedChessPiece,
        capturedPiece,
      ));

      // Switch player's turn
      lastMovedPiece = (lastMovedPiece == "white") ? "black" : "white";
    }
    notifyListeners();
  }

  // Implement this method to get the piece at a specific index
  Piece? getPieceAt(int row, int col) {
    if (row < 0 || row >= 11 || col < 0 || col >= 11) {
      // Invalid row or column
      return null;
    }
    return chessboard[row][col];
  }

  void initializeBoard() {
    for (int row = 0; row < 11; row++) {
      for (int col = 0; col < 11; col++) {
        Piece? piece; // Initialize with an empty piece
        if (row == 0 || row == 10) {
          // Initialize the top and bottom rows with black and white pieces
          final color = (row == 0) ? "black" : "white";
          final icons = (row == 0) ? blackPiecesOrder : whitePiecesOrder;
          piece = createPiece(icons[col + 1], color, row, col);
        } else if (row == 1 || row == 9) {
          // Initialize the second and second-to-last rows with pawns
          final color = (row == 1) ? "black" : "white";
          final order = (row == 1) ? blackPiecesOrder : whitePiecesOrder;
          piece = createPiece(order[0], color, row, col);
        }
        chessboard[row][col] = piece; // Assign the piece to the chessboard
      }
    }
    notifyListeners();
  }

  Piece createPiece(String icon, String color, int row, int col) {
    switch (icon) {
      case "♙":
      case "♟":
        return Infantry(icon: icon, color, CellPosition(row, col));
      case "♖":
      case "♜":
        return Tank(icon: icon, color, CellPosition(row, col));
      case "♘":
      case "♞":
        return Ghost(icon: icon, color, CellPosition(row, col));
      case "◎":
      case "◉":
        return Echo(icon: icon, color, CellPosition(row, col));
      case "♗":
      case "♝":
        return Drone(icon: icon, color, CellPosition(row, col));
      case "♕":
      case "♛":
        return Peacekeeper(icon: icon, color, CellPosition(row, col));
      case "♔":
      case "♚":
        return CommandCenter(icon: icon, color, CellPosition(row, col));
      default:
        return Piece(
            icon, color, CellPosition(row, col)); // Default empty piece
    }
  }

  void skipTurn() {
    // TODO: Implement this
    notifyListeners();
  }

  // ! NOTE: I lost my thoughts here
  void onCellClick(int row, int col) {
    log('Row: $row\nCol: $col');
    final clickedPiece = getPieceAt(row, col);

    if (selectedCell == null) {
      // No piece is selected, so select the clicked piece if it belongs to the current player
      if (clickedPiece != null && clickedPiece.color == lastMovedPiece) {
        selectedCell = CellPosition(row, col);
      }
    } else {
      // A piece is already selected, so attempt to move it to the clicked cell
      final moveSuccessful =
          _tryMovePiece(selectedCell!, CellPosition(row, col));

      if (moveSuccessful) {
        // Move was successful, update the game state
        selectedCell = null;
        lastMovedPiece = (lastMovedPiece == "white") ? "black" : "white";
      } else {
        // Move was unsuccessful, deselect the piece
        selectedCell = null;
      }
    }
    notifyListeners();
  }

  CellPosition _getCellPositionFromId(String cellId) {
    final int row = int.parse(cellId.substring(1)) - 1;
    final int col = cellId.codeUnitAt(0) - 'A'.codeUnitAt(0);
    return CellPosition(row, col);
  }

  String _getCellIdFromPosition(CellPosition position) {
    // Convert row and column indices to a cell ID format, e.g., "A1"
    final String columnLetter =
        String.fromCharCode('A'.codeUnitAt(0) + position.col);
    final String rowNumber = (position.row + 1).toString();
    return '$columnLetter$rowNumber';
  }

  bool _isValidCellPosition(CellPosition position) {
    return position.row >= 0 &&
        position.row < 11 &&
        position.col >= 0 &&
        position.col < 11;
  }

  bool _tryMovePiece(CellPosition from, CellPosition to) {
    // Check if the move is within the bounds of the chessboard
    if (!_isValidCellPosition(from) || !_isValidCellPosition(to)) {
      return false;
    }

    final Piece? movedPiece = getPieceAt(from.row, from.col);

    if (movedPiece == null) {
      // No piece to move
      return false;
    }

    // Check if the destination cell is empty or contains an opponent's piece
    final Piece? targetPiece = getPieceAt(to.row, to.col);

    if (targetPiece != null && targetPiece.color == lastMovedPiece) {
      return false; // Cannot capture own piece
    }

    // Check the specific movement rules for each piece type
    switch (movedPiece) {
      case Infantry():
        return movedPiece.canMove(from, to, chessboard);
      case Tank():
        return movedPiece.canMove(from, to, chessboard);
      case Ghost():
        return movedPiece.canMove(from, to, chessboard);
      case Echo():
        return movedPiece.canMove(from, to, chessboard);
      case Drone():
        return movedPiece.canMove(from, to, chessboard);
      case Peacekeeper():
        return movedPiece.canMove(from, to, chessboard);
      case CommandCenter():
        return movedPiece.canMove(from, to, chessboard);
    }

    return false; // Default: Invalid move
  }

  void movePiece(Piece piece, CellPosition newPosition) {
    if (piece.color == lastMovedPiece) return;
    final fromPosition = getPiecePosition(piece);

    if (fromPosition == null) {
      return; // Piece not found
    }

    if (!_tryMovePiece(fromPosition, newPosition)) {
      return; // Invalid move
    }

    // Successful move, update the chessboard
    piece.position = newPosition;
    chessboard[newPosition.row][newPosition.col] = piece;
    chessboard[fromPosition.row][fromPosition.col] = null;

    // Add the move to the history
    moveHistory.add(Move(
      _getCellIdFromPosition(fromPosition),
      _getCellIdFromPosition(newPosition),
      piece,
      null, // You can add captured piece logic later
    ));

    // Switch player's turn
    lastMovedPiece = (lastMovedPiece == "white") ? "black" : "white";

    // Notify listeners to update the UI
    notifyListeners();
  }

  CellPosition? getPiecePosition(Piece piece) {
    for (int row = 0; row < 11; row++) {
      for (int col = 0; col < 11; col++) {
        if (chessboard[row][col] == piece) {
          return CellPosition(row, col);
        }
      }
    }
    return null; // Piece not found on the chessboard
  }
}
