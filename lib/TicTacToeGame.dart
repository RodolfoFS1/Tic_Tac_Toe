import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'DatabaseHelper.dart';

class TicTacToeGame extends StatefulWidget {
  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> board = List.filled(9, ""); // Estado inicial del tablero
  bool isXTurn = true; // Alterna entre 'X' y 'O'
  String winner = "";
  int winsX = 0;
  int winsO = 0;
  int draws = 0;

  final DatabaseHelper databaseHelper = DatabaseHelper(); // Instancia del DatabaseHelper

  @override
  void initState() {
    super.initState();
    loadGame();
  }

  void handleTap(int index) {
    if (board[index] != "" || winner != "") return;

    setState(() {
      board[index] = isXTurn ? "X" : "O";
      winner = checkWinner();
      isXTurn = !isXTurn;
    });

    if (winner != "") {
      showDialogWinner();
    }
  }

  String checkWinner() {
    const List<List<int>> winningPositions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Filas
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columnas
      [0, 4, 8], [2, 4, 6] // Diagonales
    ];

    for (var pos in winningPositions) {
      String p0 = board[pos[0]],
          p1 = board[pos[1]],
          p2 = board[pos[2]];
      if (p0 != "" && p0 == p1 && p1 == p2) {
        return p0; // Retorna "X" o "O" como ganador
      }
    }

    if (!board.contains("")) {
      return "Empate";
    }
    return "";
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, "");
      winner = "";
      isXTurn = true;
    });
  }

  void newGame() {
    setState(() {
      board = List.filled(9, "");
      winner = "";
      isXTurn = true;
      winsX = 0;
      winsO = 0;
      draws = 0;
    });
  }

  void showDialogWinner() {
    String message = winner == "Empate" ? "¡Empate!" : "Ganador: $winner";
    if (winner == "X") winsX++;
    if (winner == "O") winsO++;
    if (winner == "Empate") draws++;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(message),
            actions: [
            TextButton(
            onPressed: () {
          resetGame();
          Navigator.of(context).pop();
        },
        child: Text("Continuar"),
        ),
        TextButton(
          onPressed: (){
            saveGame('NombreDeLaPartida');
            SystemNavigator.pop();
          },
          child: Text("Guardar y salir"),
        )],
    );
  },
  );
}

void showSaveGameDialog() {
  TextEditingController nameController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Guardar Partida"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: "Nombre de la partida"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              saveGame(nameController.text);
              Navigator.of(context).pop();
            },
            child: Text("Guardar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancelar"),
          ),
        ],
      );
    },
  );
}

// Guardar el estado del juego en la base de datos
  Future<void> saveGame(String name) async {
    if (name.isEmpty) return;

    Map<String, dynamic> gameData = {
      'board': jsonEncode(board), // Asegúrate de que el tablero se guarde como una cadena JSON
      'winsX': winsX,
      'winsO': winsO,
      'draws': draws,
      'isXTurn': isXTurn ? 1 : 0, // Guarda como entero
      'name': name,
    };
    await databaseHelper.insertGame(gameData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Partida guardada con éxito')),
    );
  }

// Cargar el estado del juego desde la base de datos
  Future<void> loadGame() async {
    List<Map<String, dynamic>> savedGames = await databaseHelper.getGames();
    if (savedGames.isNotEmpty) {
      showLoadGameDialog(savedGames);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Sin Partidas Guardadas"),
            content: Text("No hay partidas guardadas para cargar."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Aceptar"),
              ),
            ],
          );
        },
      );
    }
  }

  void showLoadGameDialog(List<Map<String, dynamic>> savedGames) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cargar Partida"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: savedGames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(savedGames[index]['name']),
                  onTap: () {
                    loadSelectedGame(savedGames[index]);
                    Navigator.of(context).pop(); // Cerrar el diálogo
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }


void loadSelectedGame(Map<String, dynamic> gameData) {
  setState(() {
    board = List<String>.from(jsonDecode(gameData['board']));
    winsX = gameData['winsX'];
    winsO = gameData['winsO'];
    draws = gameData['draws'];
    isXTurn = gameData['isXTurn'] == 1;
  });
}

// Menú de opciones
void showMenu(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Opciones"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                newGame();
                Navigator.of(context).pop();
              },
              child: Text("Nueva Partida"),
            ),
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
              child: Text("Reiniciar Partida"),
            ),
            TextButton(
              onPressed: () {
                loadGame();
                Navigator.of(context).pop();
              },
              child: Text("Cargar Partida"),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: Text("Salir"),
            ),
          ],
        ),
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: Text('Juego del Gato'),
      actions: [
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => showMenu(context),
        ),
      ],
    ),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 9,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => handleTap(index),
              child: Container(
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    board[index],
                    style: TextStyle(
                      fontSize: 60,
                      color: board[index] == "X"
                          ? Colors.red
                          : (board[index] == "O"
                          ? Colors.lightGreenAccent
                          : Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            winner == ""
                ? "Turno de ${isXTurn ? 'X' : 'O'}"
                : winner == "Empate"
                ? "¡Empate!"
                : "Ganador: $winner",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            "Puntuación: X: $winsX - O: $winsO - Empates: $draws",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ],
    ),
    bottomNavigationBar:
    BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () => showSaveGameDialog(),
              ),
              Text(
                'Guardar',
                style: TextStyle(fontSize: 5),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: resetGame,
              ),
              Text(
                'Reiniciar',
                style: TextStyle(fontSize: 5),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
