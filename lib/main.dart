import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const TicTacToeGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({Key? key}) : super(key: key);

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame>
    with TickerProviderStateMixin {
  late List<String> board;
  late String currentPlayer;
  late bool gameOver;
  late String? winner;
  late Map<int, AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initializeAnimations();
  }

  void _initializeGame() {
    board = List<String>.filled(9, '');
    currentPlayer = 'X';
    gameOver = false;
    winner = null;
  }

  void _initializeAnimations() {
    _animationControllers = {};
    for (int i = 0; i < 9; i++) {
      _animationControllers[i] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Check if there's a winner
  String? checkWinner() {
    // Define all winning combinations
    const List<List<int>> winningCombinations = [
      // Rows
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      // Columns
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      // Diagonals
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combination in winningCombinations) {
      String a = board[combination[0]];
      String b = board[combination[1]];
      String c = board[combination[2]];

      if (a.isNotEmpty && a == b && b == c) {
        return a;
      }
    }
    return null;
  }

  /// Check if board is full (draw)
  bool isBoardFull() {
    return board.every((cell) => cell.isNotEmpty);
  }

  /// Handle cell tap
  void onCellTap(int index) {
    if (gameOver || board[index].isNotEmpty) {
      return;
    }

    // Start animation
    _animationControllers[index]!.forward();

    setState(() {
      board[index] = currentPlayer;

      // Check for winner
      final winnerResult = checkWinner();
      if (winnerResult != null) {
        gameOver = true;
        winner = winnerResult;
        _showWinnerDialog(winnerResult);
        return;
      }

      // Check for draw
      if (isBoardFull()) {
        gameOver = true;
        _showDrawDialog();
        return;
      }

      // Switch player
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    });
  }

  /// Show winner dialog
  void _showWinnerDialog(String winnerPlayer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Text(
            'Player $winnerPlayer wins! 🎉',
            style: const TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  /// Show draw dialog
  void _showDrawDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: const Text(
            'It\'s a Draw! 🤝',
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  /// Reset the game
  void resetGame() {
    setState(() {
      _initializeGame();
      for (var controller in _animationControllers.values) {
        controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Player turn indicator
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: currentPlayer == 'X'
                    ? Colors.blue.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: currentPlayer == 'X' ? Colors.blue : Colors.orange,
                  width: 2,
                ),
              ),
              child: Text(
                'Current Player: $currentPlayer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: currentPlayer == 'X' ? Colors.blue : Colors.orange,
                ),
              ),
            ),
          ),

          // Game board
          Center(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 9,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              itemBuilder: (context, index) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationControllers[index]!,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () => onCellTap(index),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: board[index].isEmpty
                          ? Colors.white
                          : (board[index] == 'X'
                                ? Colors.blue.shade50
                                : Colors.orange.shade50),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: board[index].isEmpty
                                ? Colors.grey.shade300
                                : (board[index] == 'X'
                                      ? Colors.blue
                                      : Colors.orange),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            board[index],
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: board[index] == 'X'
                                  ? Colors.blue
                                  : (board[index] == 'O'
                                        ? Colors.orange
                                        : Colors.transparent),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Restart button
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: ElevatedButton.icon(
              onPressed: resetGame,
              icon: const Icon(Icons.refresh),
              label: const Text('Restart Game'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
