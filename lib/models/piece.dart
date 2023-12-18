import 'dart:math';

import 'position.dart';

class Piece {
  String icon;
  String color;
  CellPosition position;

  Piece(this.icon, this.color, this.position);

  // Add the canMove method that returns a boolean
  bool canMove(CellPosition from, CellPosition to, List<List<Piece?>> board) {
    // Implement this method in each specific piece type
    return false;
  }

  @override
  String toString() {
    return "${position.col} ${position.row}";
  }
}

class Infantry extends Piece {
  Infantry(String color, CellPosition position, {String? icon})
      : super(icon ?? (color == "white" ? "♙" : "♟"), color, position);

  @override
  bool canMove(CellPosition from, CellPosition to, List<List<Piece?>> board) {
    // Check if the destination cell is within bounds
    if (to.row < 0 ||
        to.row >= board.length ||
        to.col < 0 ||
        to.col >= board[0].length) {
      return false;
    }

    // Calculate the row and column difference between the current and target positions
    int rowDiff = to.row - from.row;
    int colDiff = to.col - from.col;

    // Determine the maximum allowed distance for the move
    int maxDistance = 2; // Infantry can move 1 or 2 squares forward

    // Movement logic for white pieces
    if (color == "white") {
      if (rowDiff > -1 || rowDiff < -maxDistance || colDiff.abs() > 1) {
        return false;
      }
    }

    // Movement logic for black pieces
    if (color == "black") {
      if (rowDiff < 1 || rowDiff > maxDistance || colDiff.abs() > 1) {
        return false;
      }
    }

    // Check for diagonal capture
    if (colDiff.abs() == 1 && rowDiff.abs() == 1) {
      // Diagonal capture is allowed
      Piece? targetPiece = board[to.row][to.col];
      if (targetPiece == null || targetPiece.color == color) {
        return false; // Cannot capture own piece or empty cell
      }
      return true;
    }

    // Forward movement
    if (colDiff == 0) {
      int step = color == "white" ? -1 : 1;
      int startRow = from.row + step;
      for (int i = startRow;
          color == "white" ? i > to.row : i < to.row;
          i += step) {
        if (board[i][from.col] != null) {
          return false; // Blocked by another piece
        }
      }
      return true;
    }

    return false; // Invalid move
  }
}

class Tank extends Piece {
  Tank(String color, CellPosition position, {String? icon})
      : super(icon ?? (color == "white" ? "♙" : "♟"), color, position);

  @override
  bool canMove(CellPosition from, CellPosition to, List<List<Piece?>> board) {
    // Check if the destination cell is within bounds
    if (to.row < 0 ||
        to.row >= board.length ||
        to.col < 0 ||
        to.col >= board[0].length) {
      return false;
    }

    // Calculate the row and column difference between the current and target positions
    int rowDiff = to.row - from.row;
    int colDiff = to.col - from.col;

    // Check if the move is either vertical or horizontal
    if (rowDiff != 0 && colDiff != 0) {
      return false; // Tank can only move vertically or horizontally
    }

    // Check for obstacles along the path
    int stepRow = rowDiff != 0
        ? (rowDiff > 0 ? 1 : -1)
        : 0; // Determine the direction of vertical movement
    int stepCol = colDiff != 0
        ? (colDiff > 0 ? 1 : -1)
        : 0; // Determine the direction of horizontal movement
    int distance = max(rowDiff.abs(), colDiff.abs());
    for (int i = 1; i < distance; i++) {
      if (board[from.row + i * stepRow][from.col + i * stepCol] != null) {
        return false; // Blocked by another piece
      }
    }

    // Check for capture
    Piece? targetPiece = board[to.row][to.col];
    if (targetPiece != null && targetPiece.color == color) {
      return false; // Cannot capture own piece or empty cell
    }

    return true; // Valid move
  }
}

class Ghost extends Piece {
  Ghost(String color, CellPosition position, {String? icon})
      : super(icon ?? (color == "white" ? "♙" : "♟"), color, position);

  @override
  bool canMove(CellPosition from, CellPosition to, List<List<Piece?>> board) {
    // Check if the destination cell is within bounds
    if (to.row < 0 ||
        to.row >= board.length ||
        to.col < 0 ||
        to.col >= board[0].length) {
      return false;
    }

    // Calculate the row and column difference between the current and target positions
    int rowDiff = to.row - from.row;
    int colDiff = to.col - from.col;

    // Check for the L-shape movement (2+1 or 3+1)
    if (!((rowDiff.abs() == 2 && colDiff.abs() == 1) ||
        (rowDiff.abs() == 3 && colDiff.abs() == 1) ||
        (rowDiff.abs() == 1 && colDiff.abs() == 2) ||
        (rowDiff.abs() == 1 && colDiff.abs() == 3))) {
      return false; // Ghost must move in an L-shape
    }

    // Check for capture
    Piece? targetPiece = board[to.row][to.col];
    if (targetPiece != null && targetPiece.color == color) {
      return false; // Cannot capture own piece or empty cell
    }

    return true; // Valid move
  }
}

class Echo extends Piece {
  Echo(String color, CellPosition position, {String? icon})
      : super(icon ?? (color == "white" ? "♙" : "♟"), color, position);

  @override
  bool canMove(CellPosition from, CellPosition to, List<List<Piece?>> board) {
    // Check if the destination cell is within bounds
    if (to.row < 0 ||
        to.row >= board.length ||
        to.col < 0 ||
        to.col >= board[0].length) {
      return false;
    }

    // Calculate the row and column difference between the current and target positions
    int rowDiff = to.row - from.row;
    int colDiff = to.col - from.col;

    // Check if the move is within the fixed range of 2 squares
    if (rowDiff.abs() > 2 || colDiff.abs() > 2) {
      return false; // Echo can only move up to 2 squares in any direction
    }

    // Check if the move is diagonal or vertical/horizontal
    if (rowDiff != 0 && colDiff != 0 && rowDiff.abs() != colDiff.abs()) {
      return false; // Echo can only move diagonally, vertically, or horizontally
    }

    // TODO: Echo can leap over units like Ghost
    // TODO: Not sure if its only Ghost or all units
    // TODO: Where its any unit, remove obstacle detection
    // Check for obstacles along the path
    int stepRow = rowDiff != 0 ? (rowDiff > 0 ? 1 : -1) : 0;
    int stepCol = colDiff != 0 ? (colDiff > 0 ? 1 : -1) : 0;

    for (int i = 1; i.abs() < rowDiff.abs() || i.abs() < colDiff.abs(); i++) {
      int nextRow = from.row + i * stepRow;
      int nextCol = from.col + i * stepCol;

      if (board[nextRow][nextCol] != null) {
        return false; // Blocked by another piece
      }
    }

    // Check for capture
    Piece? targetPiece = board[to.row][to.col];
    if (targetPiece != null && targetPiece.color == color) {
      return false; // Cannot capture own piece
    }

    return true; // Valid move
  }
}

class Drone extends Piece {
  Drone(String color, CellPosition position, {String? icon})
      : super(icon ?? (color == "white" ? "♙" : "♟"), color, position);

  @override
  bool canMove(CellPosition from, CellPosition to, List<List<Piece?>> board) {
    // Check if the destination cell is within bounds
    if (to.row < 0 ||
        to.row >= board.length ||
        to.col < 0 ||
        to.col >= board[0].length) {
      return false;
    }

    // Calculate the row and column difference
    int rowDiff = to.row - from.row;
    int colDiff = to.col - from.col;

    // Check for diagonal movement or single square movement in any direction
    bool isDiagonalMove = rowDiff.abs() == colDiff.abs();
    bool isSingleSquareMove = rowDiff.abs() <= 1 && colDiff.abs() <= 1;
    if (!isDiagonalMove && !isSingleSquareMove) {
      return false; // Drone must move either diagonally or a single square in any direction
    }

    // Check for obstacles along the diagonal path if it's a diagonal move
    if (isDiagonalMove && (rowDiff.abs() > 1 || colDiff.abs() > 1)) {
      int stepRow = rowDiff > 0 ? 1 : -1;
      int stepCol = colDiff > 0 ? 1 : -1;
      int steps = rowDiff.abs();
      for (int i = 1; i < steps; i++) {
        if (board[from.row + i * stepRow][from.col + i * stepCol] != null) {
          return false; // Blocked by another piece
        }
      }
    }

    // Capture logic: Capture is only allowed diagonally
    Piece? targetPiece = board[to.row][to.col];
    if (targetPiece != null) {
      if (targetPiece.color == color) {
        return false; // Cannot capture own piece
      }
      if (!isDiagonalMove) {
        return false; // Can only capture diagonally
      }
    }

    return true; // Valid move
  }
}

class Peacekeeper extends Piece {
  Peacekeeper(String color, CellPosition position, {String? icon})
      : super(icon ?? (color == "white" ? "♙" : "♟"), color, position);

  @override
  bool canMove(CellPosition from, CellPosition to, List<List<Piece?>> board) {
    // Check if the destination cell is within bounds
    if (to.row < 0 ||
        to.row >= board.length ||
        to.col < 0 ||
        to.col >= board[0].length) {
      return false;
    }

    // Calculate the row and column difference between the current and target positions
    int rowDiff = to.row - from.row;
    int colDiff = to.col - from.col;

    // Check if the move is horizontal, vertical, or diagonal
    if (rowDiff == 0 || colDiff == 0 || rowDiff.abs() == colDiff.abs()) {
      // Check for obstacles along the path based on the move direction
      int stepRow = rowDiff > 0 ? 1 : (rowDiff < 0 ? -1 : 0);
      int stepCol = colDiff > 0 ? 1 : (colDiff < 0 ? -1 : 0);

      int nextRow = from.row + stepRow;
      int nextCol = from.col + stepCol;

      while (nextRow != to.row || nextCol != to.col) {
        if (board[nextRow][nextCol] != null) {
          return false; // Blocked by another piece
        }
        nextRow += stepRow;
        nextCol += stepCol;
      }

      // Check for capture
      Piece? targetPiece = board[to.row][to.col];
      if (targetPiece != null && targetPiece.color == color) {
        return false; // Cannot capture own piece
      }

      return true; // Valid move
    }

    return false; // Invalid move
  }
}

class CommandCenter extends Piece {
  CommandCenter(String color, CellPosition position, {String? icon})
      : super(icon ?? (color == "white" ? "♙" : "♟"), color, position);

  @override
  bool canMove(CellPosition from, CellPosition to, List<List<Piece?>> board) {
    // Check if the destination cell is within bounds
    if (to.row < 0 ||
        to.row >= board.length ||
        to.col < 0 ||
        to.col >= board[0].length) {
      return false;
    }

    // Calculate the row and column difference between the current and target positions
    int rowDiff = to.row - from.row;
    int colDiff = to.col - from.col;

    // Check if the move is within a single square in any direction
    if (rowDiff.abs() > 1 || colDiff.abs() > 1) {
      return false; // Command Center can only move one square in any direction
    }

    // Check if the move is within a single square in any direction
    if (rowDiff >= -1 && rowDiff <= 1 && colDiff >= -1 && colDiff <= 1) {
      // Check for capture
      Piece? targetPiece = board[to.row][to.col];
      if (targetPiece != null && targetPiece.color == color) {
        return false; // Cannot capture own piece
      }

      return true; // Valid move
    }

    return false; // Invalid move
  }
}
