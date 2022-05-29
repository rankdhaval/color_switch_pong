import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/size_config.dart';

enum Direction { UP, DOWN, LEFT, RIGHT }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool gameHasStarted = false;
  double ballX = 0;
  double ballY = 0.84;
  double playerX = 0;
  double enemyX = -0.2;
  double playerWidth = 0.4;
  Direction ballYDirection = Direction.DOWN;
  Color selectedColor = Colors.pink;
  Color brickColor = Colors.pink;
  Color ballColor = Colors.pink;
  int score = 0;

  //score objrct variable
  Color pointObjectColor = Colors.pink;
  double pointObjectHeight = 20;
  double pointObjectWidth = 20;
  double pointObjectX = 20;
  double pointObjectY = 20;

  List<Color> colors = [
    Colors.pink,
    Colors.yellowAccent,
    Colors.deepPurple,
    Colors.cyan
  ];

  Direction ballXDirection = Direction.LEFT;

  void getRandomValuesForScoreObject() {
    final _random = Random();
    setState(() {
      pointObjectColor = colors[_random.nextInt(colors.length)];
      pointObjectHeight = 20;
      pointObjectWidth = _random.nextInt(300 - 100).toDouble();
      bool xval = _random.nextBool();
      pointObjectX = (_random.nextInt(10) / 15) * (xval == true ? 1 : -1);
      bool yval = _random.nextBool();
      pointObjectY = (_random.nextInt(10) / 30) * (yval == true ? 1 : -1);
    });
  }

  void updateDirection() {
    setState(() {
      if (ballY >= 0.84 && playerX + playerWidth >= ballX && playerX <= ballX) {
        ballYDirection = Direction.UP;
        ballColor = brickColor;
      } else if (ballY <= -0.9) {
        ballYDirection = Direction.DOWN;
      }
      if (ballX >= 1) {
        ballXDirection = Direction.LEFT;
      } else if (ballX <= -1) {
        ballXDirection = Direction.RIGHT;
      }
    });
  }

  void moveLeft() {
    setState(() {
      if (!(playerX - 0.1 <= -1)) playerX -= 0.1;
    });
  }

  void moveRight() {
    setState(() {
      if (!(playerX + playerWidth >= 1)) playerX += 0.1;
    });
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 1), (timer) {
      setState(() {
        updateDirection();
        moveBall();
        moveEnemy();
        scoreCounter();
        if (isPlayerDead()) {
          timer.cancel();
          reSetGame();
        }
      });
    });
  }

  void scoreCounter() {
    print((pointObjectX +
        SizeConfig.getAlignmentOfScoringObject(pointObjectWidth)));
    print((pointObjectX -
        SizeConfig.getAlignmentOfScoringObject(pointObjectWidth)));
    setState(() {
      if (ballX <
              (pointObjectX +
                  SizeConfig.getAlignmentOfScoringObject(pointObjectWidth)) &&
          ballX >
              (pointObjectX -
                  SizeConfig.getAlignmentOfScoringObject(pointObjectWidth)) &&
          ballY < 0.005 &&
          ballY > -0.005) {
        score++;
      }
      print(score);
    });
  }

  void moveEnemy() {
    setState(() {
      enemyX = ballX;
    });
  }

  void reSetGame() {
    setState(() {
      gameHasStarted = false;
      ballX = 0;
      ballY = 0.84;
      playerX = -0.2;
      enemyX = -0.2;
    });
  }

  bool isPlayerDead() {
    if (ballY >= 1) {
      return true;
    }
    return false;
  }

  void moveBall() {
    setState(() {
      if (ballYDirection == Direction.DOWN) {
        ballY += 0.008;
      } else if (ballYDirection == Direction.UP) {
        ballY -= 0.008;
      }

      if (ballXDirection == Direction.LEFT) {
        ballX -= 0.008;
      } else if (ballXDirection == Direction.RIGHT) {
        ballX += 0.008;
      }
    });
  }

  @override
  void initState() {
    getRandomValuesForScoreObject();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }
      },
      child: GestureDetector(
        onTap: startGame,
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          body: Center(
            child: Stack(
              children: [
                CoverScreen(gameHasStarted: gameHasStarted),
                MyBrick(
                  x: enemyX,
                  y: -1,
                  playerWidth: playerWidth,
                  color: Colors.white,
                ),
                MyBrick(
                  x: playerX,
                  y: 0.9,
                  playerWidth: playerWidth,
                  color: brickColor,
                ),
                MyBall(
                  x: ballX,
                  y: ballY,
                  myBallColor: ballColor,
                ),
                Container(
                  alignment: Alignment(0, 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                        colors.length,
                        (index) => ColorOptions(
                              color: colors[index],
                              selected: selectedColor == colors[index],
                              onTap: () {
                                setState(() {
                                  selectedColor = colors[index];
                                  brickColor = selectedColor;
                                });
                              },
                            )),
                  ),
                ),
                PointObject(
                  color: pointObjectColor,
                  width: pointObjectWidth,
                  height: pointObjectHeight,
                  x: pointObjectX,
                  y: pointObjectY,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ColorOptions extends StatelessWidget {
  final void Function() onTap;
  final Color color;
  final bool selected;

  const ColorOptions(
      {Key? key,
      required this.onTap,
      required this.color,
      required this.selected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
            border: selected ? Border.all(width: 3, color: Colors.white) : null,
            shape: BoxShape.circle,
            color: color),
      ),
    );
  }
}

class MyBrick extends StatelessWidget {
  final double x;
  final double y;
  final double playerWidth;
  final Color color;

  MyBrick(
      {required this.x,
      required this.y,
      required this.playerWidth,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment((2 * x + playerWidth) / (2 - playerWidth), y),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: color,
          height: 20,
          width: MediaQuery.of(context).size.width * playerWidth / 2,
        ),
      ),
    );
  }
}

class MyBall extends StatelessWidget {
  final double x;
  final double y;
  final Color myBallColor;

  MyBall({required this.x, required this.y, required this.myBallColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(x, y),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: myBallColor,
        ),
        width: 20,
        height: 20,
      ),
    );
  }
}

class CoverScreen extends StatelessWidget {
  final bool gameHasStarted;

  CoverScreen({required this.gameHasStarted});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(0, -0.2),
      child: Text(gameHasStarted ? "" : "Tap to Start"),
    );
  }
}

class PointObject extends StatelessWidget {
  final double x;
  final double y;
  final double width;
  final Color color;
  double height = 20;

  PointObject(
      {Key? key,
      required this.x,
      required this.y,
      required this.width,
      this.height = 20,
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(x, y),
      child: Container(
        width: width,
        height: height,
        color: color,
      ),
    );
  }
}
