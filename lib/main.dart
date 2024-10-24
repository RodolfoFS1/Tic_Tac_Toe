import 'package:flutter/material.dart';
import 'TicTacToeGame.dart';

void main() {
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic-Tac-Toe',
      theme: ThemeData(primarySwatch: Colors.lightGreen),
      home: TicTacToeGame(),
    );
  }
}