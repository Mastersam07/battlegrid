import 'package:battlegrid/chessboard.dart';
import 'package:flutter/material.dart';

import 'controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Operation BattleGrid: Strategic Frontiers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ChessGame chessGame = ChessGame();
  @override
  void initState() {
    chessGame.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ChessboardGrid(chessGame),
              const SizedBox(height: 20.0),
              Wrap(
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => chessGame.undoMove(),
                    child: const Text('Undo Move'),
                  ),
                  ElevatedButton(
                    onPressed: () => chessGame.skipTurn(),
                    child: const Text('Skip Turn'),
                  ),
                  ElevatedButton(
                    onPressed: () => chessGame.exportMoves(),
                    child: const Text('Export Moves'),
                  ),
                  ElevatedButton(
                    onPressed: () => chessGame.importMoves(
                        "♕ from G11 to G4;♟ from G2 to C9;◎ from I11 to B4;♟ from K2 to J9"),
                    child: const Text('Import Moves'),
                  ),
                  ElevatedButton(
                    onPressed: () => chessGame.resetGameState(),
                    child: const Text('Restart Game'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
