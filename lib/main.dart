import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // all types of tetrominoes
  final List<List<int>> tetrominoes = [
    [3, 4, 5, 6], //I
    [4, 14, 15, 16], //J
    [5, 13, 14, 15], //L
    [4, 5, 14, 15], //O
    [4, 5, 13, 14], //S
    [4, 13, 14, 15], //T
    [3, 4, 14, 15], //Z
  ];
  final int noOfCells = 200;
  int currentTetrominoType = 0;
  int currentRotation = 0;
  List<int> currentTetromino = [];
  Set<int> blockedCells = {};
  int interval = 500; //miliseconds

  List<int?> currentGrid = List.generate(200, (index) => null);

  bool gameInProgress = false;

  bool isValidMove(tetromino) {
    for (var i = 0; i < tetromino.length; i++) {
      if (tetromino[i] >= noOfCells || currentGrid[tetromino[i]] != null) {
        return false;
      }
    }
    return true;
  }

  void handleStartClick() {
    setState(() {
      gameInProgress = true;
    });
    startTimer();
  }

  void startTimer() {
    currentTetromino = new List.from(tetrominoes[currentTetrominoType]);
    currentRotation = 0;

    Timer.periodic(
      Duration(milliseconds: interval),
      (Timer timer) {
        setState(() {
          List<int> newPosition = [];
          for (var i = 0; i < currentTetromino.length; i++) {
            newPosition.add(currentTetromino[i] + 10);
          }
          if (isValidMove(newPosition)) {
            currentTetromino.forEach((pos) {
              currentGrid[pos] = null;
            });
            newPosition.forEach((pos) {
              currentGrid[pos] = currentTetrominoType;
            });
            currentTetromino = newPosition;
          } else {
            timer.cancel();
            startTimer();
          }
        });
      },
    );
  }

  void moveLeft() {
    setState(() {
      bool canMove = currentGrid[currentTetromino.first - 1] == null &&
          currentTetromino.every((pos) => pos % 10 > 0);

      if (canMove) {
        currentTetromino.forEach((pos) {
          currentGrid[pos] = null;
        });
        currentTetromino = currentTetromino.map((e) => e - 1).toList();
      }
      currentTetromino.forEach((pos) {
        currentGrid[pos] = currentTetrominoType;
      });
    });
  }

  void moveRight() {
    setState(() {
      bool canMove = currentGrid[currentTetromino.last + 1] == null &&
          currentTetromino.every((pos) => pos % 10 < 9);
      if (canMove) {
        currentTetromino.forEach((pos) {
          currentGrid[pos] = null;
        });
        currentTetromino = currentTetromino.map((e) => e + 1).toList();
      }
      currentTetromino.forEach((pos) {
        currentGrid[pos] = currentTetrominoType;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 280,
            height: 670,
            color: Colors.deepPurple,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 10,
                    children: List.generate(
                        noOfCells,
                        (index) => Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                color: currentGrid[index] != null
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            )),
                  ),
                ),
                Container(
                  color: Colors.white12,
                  child: Center(
                    child: Container(
                      height: 110,
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              iconSize: 60,
                              onPressed: moveLeft,
                              icon: Icon(
                                Icons.arrow_left_rounded,
                              )),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                  iconSize: 30,
                                  onPressed: () => {},
                                  icon: Icon(
                                    Icons.rotate_right,
                                  )),
                              IconButton(
                                  onPressed: () => {},
                                  iconSize: 30,
                                  icon: Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                  )),
                            ],
                          ),
                          IconButton(
                              onPressed: moveRight,
                              iconSize: 60,
                              icon: Icon(
                                Icons.arrow_right_rounded,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: gameInProgress ? null : handleStartClick,
                    child: Text('START GAME'),
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(140, 60), primary: Colors.deepPurple))
              ],
            ),
          )
        ],
      ),
    ));
  }
}
