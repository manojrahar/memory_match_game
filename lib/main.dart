import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MemoryGameApp());
}

class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memory Match Game',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF3EFFF),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> emojis = [
    '🚀', '💻', '🎮', '🔥',
    '🚀', '💻', '🎮', '🔥',
    '⭐', '❤️', '🎯', '🎵',
    '⭐', '❤️', '🎯', '🎵',
  ];

  List<bool> revealed = List.generate(16, (_) => false);
  List<bool> matched = List.generate(16, (_) => false);

  int? firstIndex;
  int? secondIndex;

  int moves = 0;
  int timerSeconds = 0;
  int bestScore = 999;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    emojis.shuffle();
    revealed = List.generate(16, (_) => false);
    matched = List.generate(16, (_) => false);
    firstIndex = null;
    secondIndex = null;
    moves = 0;
    timerSeconds = 0;

    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timerSeconds++;
      });
    });

    setState(() {});
  }

  void onCardTap(int index) {
    if (revealed[index] || matched[index]) return;

    setState(() {
      revealed[index] = true;
    });

    if (firstIndex == null) {
      firstIndex = index;
    } else {
      secondIndex = index;
      moves++;
      checkMatch();
    }
  }

  void checkMatch() {
    if (firstIndex == null || secondIndex == null) return;

    if (emojis[firstIndex!] == emojis[secondIndex!]) {
      setState(() {
        matched[firstIndex!] = true;
        matched[secondIndex!] = true;
      });

      if (matched.every((card) => card)) {
        gameTimer?.cancel();

        if (moves < bestScore) {
          bestScore = moves;
        }

        Future.delayed(const Duration(milliseconds: 300), showWinDialog);
      }

      firstIndex = null;
      secondIndex = null;
    } else {
      Timer(const Duration(milliseconds: 700), () {
        setState(() {
          revealed[firstIndex!] = false;
          revealed[secondIndex!] = false;
        });
        firstIndex = null;
        secondIndex = null;
      });
    }
  }

  void showWinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("🎉 Congratulations!"),
        content: Text(
          "You completed the game in $moves moves\nTime: $timerSeconds sec\nBest Score: $bestScore",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startGame();
            },
            child: const Text("Play Again"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Moves: $moves | ⏱ $timerSeconds s"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: startGame,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "🏆 Best Score: $bestScore",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: emojis.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final isVisible = revealed[index] || matched[index];

                  return GestureDetector(
                    onTap: () => onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isVisible
                            ? Colors.white
                            : Colors.deepPurple,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            offset: Offset(2, 4),
                            color: Colors.black12,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isVisible ? emojis[index] : '?',
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
