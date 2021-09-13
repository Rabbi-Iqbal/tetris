import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
    [13, 14, 5, 15], //L
    [4, 14, 5, 15], //O
    [13, 4, 14, 5], //S
    [13, 4, 14, 15], //T
    [3, 4, 14, 15], //Z
  ];
  final int noOfCells = 200;
  int currentTetrominoType = 0;
  int currentRotation = 0;
  List<int> currentTetromino = [];
  Set<int> blockedCells = {};
  bool gameOver = false;
  int interval = 500; //miliseconds

  List<int?> currentGrid = List.generate(200, (index) => null);

  bool gameInProgress = false;

  int score = 0;

  late Timer _timer;

  bool isValidMove(tetromino) {
    for (var i = 0; i < tetromino.length; i++) {
      if (currentTetromino.contains(tetromino[i])) continue;
      if (tetromino[i] >= noOfCells ||
          tetromino[i] < 0 ||
          currentGrid[tetromino[i]] != null) {
        return false;
      }
    }
    return true;
  }

  void spawnRandomTetromino() {
    Random random = new Random();
    int randomNumber = random.nextInt(7);
    setState(() {
      currentTetromino = new List.from(tetrominoes[randomNumber]);
      // currentTetromino = new List.from(tetrominoes[1]);
      currentRotation = 0;
      currentTetrominoType = randomNumber;
      // currentTetrominoType = 0;
      for (int i = 0; i < currentTetromino.length; i++) {
        if (currentGrid[currentTetromino[i]] != null) {
          gameInProgress = false;
          gameOver = true;
          _timer.cancel();
          break;
        }
        currentGrid[currentTetromino[i]] = currentTetrominoType;
      }
    });
  }

  void handleStartClick() {
    setState(() {
      gameInProgress = true;
      currentGrid = List.generate(200, (index) => null);
      gameOver = false;
      score = 0;
    });

    spawnRandomTetromino();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(
      Duration(milliseconds: interval),
      (timer) {
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
            checkForMatchedPattern();
            spawnRandomTetromino();
          }
        });
      },
    );
  }

  void moveDown() {
    if (!gameInProgress) {
      return;
    }
    _timer.cancel();
    while (true) {
      List<int> newPosition = [];
      currentTetromino.forEach((pos) {
        newPosition.add(pos + 10);
      });
      if (isValidMove(newPosition)) {
        setState(() {
          currentTetromino.forEach((pos) {
            currentGrid[pos] = null;
          });
          newPosition.forEach((pos) {
            currentGrid[pos] = currentTetrominoType;
          });
          currentTetromino = newPosition;
        });
      } else {
        break;
      }
    }
    checkForMatchedPattern();
    spawnRandomTetromino();
    startTimer();
  }

  void moveLeft() {
    if (!gameInProgress) {
      return;
    }
    setState(() {
      //check if there a free cell to the left
      bool canMove = currentTetromino.first % 10 > 0;

      //compute the new position and check if it is valid. This will take care of the collision.
      List<int> newPosition = currentTetromino.map((e) => e - 1).toList();

      if (canMove && isValidMove(newPosition)) {
        currentTetromino.forEach((pos) {
          currentGrid[pos] = null;
        });
        newPosition.forEach((pos) {
          currentGrid[pos] = currentTetrominoType;
        });
        currentTetromino = newPosition;
      }
    });
  }

  void moveRight() {
    if (!gameInProgress) {
      return;
    }
    setState(() {
      bool canMove = currentTetromino.last % 10 < 9;
      List<int> newPosition = currentTetromino.map((e) => e + 1).toList();
      if (canMove && isValidMove(newPosition)) {
        currentTetromino.forEach((pos) {
          currentGrid[pos] = null;
        });
        newPosition.forEach((pos) {
          currentGrid[pos] = currentTetrominoType;
        });
        currentTetromino = newPosition;
      }
    });
  }

  void updateCurrentGrid(prev, next) {
    prev.forEach((pos) {
      currentGrid[pos] = null;
    });
    next.forEach((pos) {
      currentGrid[pos] = currentTetrominoType;
    });

    currentTetromino = next;
  }

  void rotateZ() {
    currentRotation = ++currentRotation % 4;
    setState(() {
      List<int> newPostion = List.from(currentTetromino);
      if (currentRotation == 1) {
        newPostion[0] = currentTetromino[2];
        newPostion[1] = currentTetromino[2] + 10;
        newPostion[2] = currentTetromino[2] - 9;
        newPostion[3] = currentTetromino[2] + 1;
        updateCurrentGrid(currentTetromino, newPostion);
      }
      if (currentRotation == 2) {
        newPostion[0] = currentTetromino[0] - 1;
        newPostion[1] = currentTetromino[0];
        newPostion[2] = currentTetromino[0] + 10;
        newPostion[3] = currentTetromino[0] + 11;
        bool canMove = (currentTetromino.first % 10) > 0;
        if (canMove && isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 3) {
        newPostion[0] = currentTetromino[1] - 1;
        newPostion[1] = currentTetromino[1] + 9;
        newPostion[2] = currentTetromino[1] - 10;
        newPostion[3] = currentTetromino[1];
        updateCurrentGrid(currentTetromino, newPostion);
      }
      if (currentRotation == 0) {
        newPostion[0] = currentTetromino[3] - 11;
        newPostion[1] = currentTetromino[3] - 10;
        newPostion[2] = currentTetromino[3];
        newPostion[3] = currentTetromino[3] + 1;
        bool canMove = (currentTetromino.last % 10) < 9;
        if (canMove && isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
    });
  }

  void rotateL() {
    currentRotation = ++currentRotation % 4;
    setState(() {
      List<int> newPostion = List.from(currentTetromino);
      if (currentRotation == 1) {
        newPostion[0] = currentTetromino[1] - 10;
        newPostion[1] = currentTetromino[1];
        newPostion[2] = currentTetromino[1] + 10;
        newPostion[3] = currentTetromino[1] + 11;
        if (isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 2) {
        newPostion[0] = currentTetromino[1] - 1;
        newPostion[1] = currentTetromino[1] + 9;
        newPostion[2] = currentTetromino[1];
        newPostion[3] = currentTetromino[1] + 1;
        bool canMove = (currentTetromino.first % 10) > 0;
        if (canMove && isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 3) {
        newPostion[0] = currentTetromino[2] - 11;
        newPostion[1] = currentTetromino[2] - 10;
        newPostion[2] = currentTetromino[2];
        newPostion[3] = currentTetromino[2] + 10;
        if (isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 0) {
        newPostion[0] = currentTetromino[2] - 1;
        newPostion[1] = currentTetromino[2];
        newPostion[2] = currentTetromino[2] - 9;
        newPostion[3] = currentTetromino[2] + 1;
        bool canMove = (currentTetromino.last % 10) < 9;
        if (canMove && isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
    });
  }

  void checkForMatchedPattern() {
    for (int i = 0; i < 199; i += 10) {
      bool filled = true;
      for (int j = i; j < i + 10; j++) {
        if (currentGrid[j] == null) {
          filled = false;
          break;
        }
      }
      if (filled) {
        setState(() {
          currentGrid.removeRange(i, i + 10);
          List<int?> emptyRow = List.generate(10, (index) => null);
          currentGrid = [...emptyRow, ...currentGrid];
          score += 100;
        });
      }
    }
  }

  void rotateS() {
    currentRotation = ++currentRotation % 4;
    setState(() {
      List<int> newPostion = List.from(currentTetromino);
      if (currentRotation == 1) {
        newPostion[0] = currentTetromino[2] - 10;
        newPostion[1] = currentTetromino[2];
        newPostion[2] = currentTetromino[2] + 1;
        newPostion[3] = currentTetromino[2] + 11;
        if (isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 2) {
        newPostion[0] = currentTetromino[1] + 9;
        newPostion[1] = currentTetromino[1];
        newPostion[2] = currentTetromino[1] + 10;
        newPostion[3] = currentTetromino[1] + 1;
        bool canMove = (currentTetromino.first % 10) > 0;
        if (canMove && isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 3) {
        newPostion[0] = currentTetromino[1] - 11;
        newPostion[1] = currentTetromino[1] - 1;
        newPostion[2] = currentTetromino[1];
        newPostion[3] = currentTetromino[1] + 10;
        if (isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 0) {
        newPostion[0] = currentTetromino[2] - 1;
        newPostion[1] = currentTetromino[2] - 10;
        newPostion[2] = currentTetromino[2];
        newPostion[3] = currentTetromino[2] - 9;
        bool canMove = (currentTetromino.last % 10) < 9;
        if (canMove && isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
    });
  }

  void rotateJ() {
    currentRotation = ++currentRotation % 4;
    setState(() {
      List<int> newPostion = List.from(currentTetromino);
      if (currentRotation == 1) {
        newPostion[0] = currentTetromino[2] - 10;
        newPostion[1] = currentTetromino[2];
        newPostion[2] = currentTetromino[2] + 10;
        newPostion[3] = currentTetromino[2] - 9;

        if (isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 2) {
        newPostion[0] = currentTetromino[1] - 1;
        newPostion[1] = currentTetromino[1];
        newPostion[2] = currentTetromino[1] + 1;
        newPostion[3] = currentTetromino[1] + 11;

        bool canMove = (currentTetromino.first % 10) > 0;
        if (canMove && isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 3) {
        newPostion[0] = currentTetromino[1] + 9;
        newPostion[1] = currentTetromino[1] - 10;
        newPostion[2] = currentTetromino[1];
        newPostion[3] = currentTetromino[1] + 10;
        if (isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 0) {
        newPostion[0] = currentTetromino[2] - 11;
        newPostion[1] = currentTetromino[2] - 1;
        newPostion[2] = currentTetromino[2];
        newPostion[3] = currentTetromino[2] + 1;
        bool canMove = (currentTetromino.last % 10) < 9;
        if (canMove && isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
    });
  }

  void rotateT() {
    currentRotation = ++currentRotation % 4;
    setState(() {
      List<int> newPostion = List.from(currentTetromino);
      if (currentRotation == 1) {
        newPostion[0] = currentTetromino[2] + 10;
        newPostion[1] = currentTetromino[2];
        newPostion[2] = currentTetromino[2] - 10;
        newPostion[3] = currentTetromino[2] + 1;
        if (isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 2) {
        newPostion[0] = currentTetromino[1] - 1;
        newPostion[1] = currentTetromino[1];
        newPostion[2] = currentTetromino[1] + 10;
        newPostion[3] = currentTetromino[1] + 1;
        bool canMove = (currentTetromino.first % 10) > 0;
        if (canMove && isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 3) {
        newPostion[0] = currentTetromino[1] - 1;
        newPostion[1] = currentTetromino[1] - 10;
        newPostion[2] = currentTetromino[1];
        newPostion[3] = currentTetromino[1] + 10;
        if (isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 0) {
        newPostion[0] = currentTetromino[2] - 1;
        newPostion[1] = currentTetromino[2] - 10;
        newPostion[2] = currentTetromino[2];
        newPostion[3] = currentTetromino[2] + 1;
        bool canMove = (currentTetromino.last % 10) < 9;
        if (canMove && isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
    });
  }

  void rotateI() {
    currentRotation = ++currentRotation % 4;

    setState(() {
      List<int> newPostion = List.from(currentTetromino);
      if (currentRotation == 1) {
        newPostion[0] = currentTetromino[1] - 10;
        newPostion[1] = currentTetromino[1];
        newPostion[2] = currentTetromino[1] + 10;
        newPostion[3] = currentTetromino[1] + 20;
        if (isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 2) {
        // down -> left
        newPostion[0] = currentTetromino[1] - 2;
        newPostion[1] = currentTetromino[1] - 1;
        newPostion[2] = currentTetromino[1];
        newPostion[3] = currentTetromino[1] + 1;
        // this is to ensure that there are atleast 2 cells free to the left
        //and 1 cell free to the right (if positioned on the right edge)
        bool canMove = (currentTetromino.first % 10) > 1 &&
            (currentTetromino.last % 10) < 9;
        if (canMove && isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 3) {
        newPostion[0] = currentTetromino[2] - 20;
        newPostion[1] = currentTetromino[2] - 10;
        newPostion[2] = currentTetromino[2];
        newPostion[3] = currentTetromino[2] + 10;
        if (isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
      if (currentRotation == 0) {
        // up -> right
        newPostion[0] = currentTetromino[2] - 1;
        newPostion[1] = currentTetromino[2];
        newPostion[2] = currentTetromino[2] + 1;
        newPostion[3] = currentTetromino[2] + 2;
        // this is to ensure that there are atleast 2 cells free to the right
        //and 1 cell free to the left (if positioned on the left edge)
        bool canMove = (currentTetromino.last % 10) < 8 &&
            (currentTetromino.first % 10) > 0;
        if (canMove && isValidMove(newPostion))
          updateCurrentGrid(currentTetromino, newPostion);
        else
          currentRotation--;
      }
    });
  }

  Color getColor(tetrominoType) {
    if (tetrominoType == 0) return Colors.amber; //I
    if (tetrominoType == 1) return Colors.orange.shade200; //J
    if (tetrominoType == 2) return Colors.brown.shade200; //L
    if (tetrominoType == 3) return Colors.pink.shade200; //O
    if (tetrominoType == 4) return Colors.blue.shade200; //S
    if (tetrominoType == 5) return Colors.green.shade200; //T
    if (tetrominoType == 6) return Colors.red.shade200; //Z

    return Colors.white;
  }

  void rotate() {
    if (!gameInProgress) {
      return;
    }
    if (currentTetrominoType == 0) rotateI();
    if (currentTetrominoType == 1) rotateJ();
    if (currentTetrominoType == 2) rotateL();
    if (currentTetrominoType == 4) rotateS();
    if (currentTetrominoType == 5) rotateT();
    if (currentTetrominoType == 6) rotateZ();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (RawKeyEvent event) {
              // if (event.runtimeType.toString() == 'RawKeyDownEvent') {
                if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
                  rotate();
                }
                if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
                  moveDown();
                }
                if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
                  moveLeft();
                }
                if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                  moveRight();
                }
              // }
            },
            autofocus: true,
            child: Center(
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
                                            ? getColor(currentGrid[index])
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                      iconSize: 60,
                                      onPressed: moveLeft,
                                      icon: Icon(
                                        Icons.arrow_left_rounded,
                                      )),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                          iconSize: 30,
                                          onPressed: rotate,
                                          icon: Icon(
                                            Icons.rotate_right,
                                          )),
                                      IconButton(
                                          onPressed: moveDown,
                                          iconSize: 30,
                                          icon: Icon(
                                            Icons
                                                .arrow_drop_down_circle_outlined,
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
                        Container(
                          margin: EdgeInsets.only(left: 40),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KEYBOARD CONTROLS',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Left Arrow - Move Left',
                                ),
                                Text('Right Arrow - Move Right'),
                                Text('Up Arrow - Rotate (clockwise)'),
                                Text('Down Arrow - Hard Drop'),
                                SizedBox(height: 10),
                              ]),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          child: Text(gameOver ? 'GAME OVER!' : '',
                              style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          width: 140,
                          height: 100,
                          color: Colors.black,
                          child: Center(
                            child: Container(
                              height: 70,
                              width: 110,
                              color: Colors.grey,
                              child: Center(
                                child: Text(score.toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 140,
                          height: 35,
                          margin: EdgeInsets.only(bottom: 30.0),
                          decoration: new BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: new BorderRadius.only(
                                bottomLeft: const Radius.circular(5.0),
                                bottomRight: const Radius.circular(5.0),
                              )),
                          child: Center(
                            child: Center(
                              child: Text('Score',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                            ),
                          ),
                        ),
                        ElevatedButton(
                            onPressed: gameInProgress ? null : handleStartClick,
                            child: Text(
                              'START GAME',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size(140, 60),
                                primary: Colors.deepPurple))
                      ],
                    ),
                  )
                ],
              ),
            )));
  }
}
