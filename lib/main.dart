import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class Player {
  String playerName;
  int score;

  Player({required this.playerName, required this.score});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int score = 0;
  int litSquareIndex = -1;
  bool gameOver = false;
  List<Player> highScores = [
    Player(playerName: 'Player1', score: 0),
    Player(playerName: 'Player2', score: 0),
    Player(playerName: 'Player3', score: 0),
    Player(playerName: 'Player4', score: 0),
    Player(playerName: 'Player5', score: 0),
  ];
  String playerName = "";
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Start the game when the screen loads
    startGame();
  }

  void startGame() {
    // Cancel the existing timer
    timer?.cancel();

    // Set up a timer to change the lit square at 1-second intervals
    const duration = const Duration(seconds: 1);
    timer = Timer.periodic(duration, (Timer timer) {
      // Update the lit square index to a random value
      setState(() {
        litSquareIndex = Random().nextInt(25);
      });
    });
  }

  void handleSquareTap(int index) {
    // Check if the game is over
    if (gameOver) {
      return;
    }

    // Check if the tapped square is the lit square
    if (index == litSquareIndex) {
      // If yes, increase the score
      setState(() {
        score += 1;
      });
    } else {
      // If no, trigger game over
      gameOver = true;
      // Check if the new score is a high score
      checkHighScore();
      // Show the "Game Over" message
      showGameOverDialog();
    }
  }

  void checkHighScore() {
    // Check if current score is higher than any of the top 5 scores
    for (int i = 0; i < highScores.length; i++) {
      if (score > highScores[i].score) {
        // If higher prompt the user to enter a 3-letter name
        enterPlayerName(i);
        break;
      }
    }
  }

  void enterPlayerName(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New High Score!'),
          content: TextField(
            maxLength: 3,
            onChanged: (value) {
              playerName = value;
            },
            decoration: InputDecoration(labelText: 'Enter Your Name (3 letters)'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Save the player name and update the high scores
                setState(() {
                  highScores.insert(index, Player(playerName: playerName, score: score));
                  highScores.removeLast();
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showGameOverDialog() {
    // Cancel the timer when the game is over
    timer?.cancel();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Your final score is: $score'),
          actions: [
            TextButton(
              onPressed: () {
                // Reset the game
                setState(() {
                  score = 0;
                  gameOver = false;
                });
                Navigator.of(context).pop();
                // Start a new game
                startGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void showLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderboardScreen(highScores: highScores),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hit the Box'),
        actions: [
          IconButton(
            onPressed: showLeaderboard,
            icon: Icon(Icons.leaderboard),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the score
            Text(
              'Score: $score',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            // Display the 5x5 grid of smaller squares
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5,),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => handleSquareTap(index),
                  child: Container(
                    margin: EdgeInsets.all(2), 
                    color: litSquareIndex == index
                        ? Colors.yellow
                        : (gameOver ? Colors.grey : Colors.blue), // Change color on game over
                    height: 30, 
                    width: 30, 
                  ),
                );
              },
              itemCount: 25,
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  final List<Player> highScores;

  LeaderboardScreen({required this.highScores});

  @override
  Widget build(BuildContext context) {
    // Sort the high scores in descending order
    List<Player> sortedHighScores = List.from(highScores);
    sortedHighScores.sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: ListView.builder(
        itemCount: sortedHighScores.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Rank ${index + 1}: ${sortedHighScores[index].playerName} - ${sortedHighScores[index].score}'),
          );
        },
      ),
    );
  }
}
