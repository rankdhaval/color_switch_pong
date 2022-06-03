import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/assets.dart';
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
  double playerX = -0.2;
  double enemyX = -0.2;
  double playerWidth = 0.4;
  Direction ballYDirection = Direction.DOWN;
  Color selectedColor = Colors.pink;
  Color brickColor = Colors.pink;
  Color ballColor = Colors.pink;
  int score = 0;
  int life = 3;

  Timer? _timer;

  //score objrct variable
  GemModel pointObject = GemModel(color: Colors.pink, path: pinkGem);
  double pointObjectHeight = 20;
  double pointObjectWidth = 20;
  double pointObjectX = 20;
  double pointObjectY = 20;

  //ball speed
  double ballSpeedX = 0.003;
  double ballSpeedY = 0.003;

  List<Color> colors = [
    Colors.pink,
    Colors.green,
    Colors.deepPurple,
    Colors.cyan
  ];

  List<GemModel> scores = [
    GemModel(color: Colors.pink, path: pinkGem),
    GemModel(color: Colors.green, path: greenGem),
    GemModel(color: Colors.deepPurple, path: purpleGem),
    GemModel(color: Colors.cyan, path: skyGem),
  ];

  Direction ballXDirection = Direction.LEFT;

  void getRandomValuesForScoreObject() {
    final _random = Random();
    setState(() {
      pointObject = scores[_random.nextInt(colors.length)];
      bool xval = _random.nextBool();
      pointObjectX = (_random.nextInt(10) / 15) * (xval == true ? 1 : -1);
      bool yval = _random.nextBool();
      pointObjectY = (_random.nextInt(10) / 30) * (yval == true ? 1 : -1);
    });
  }

  void updateDirection() {
    if (ballY >= 0.84 && playerX + playerWidth >= ballX && playerX <= ballX) {
      ballYDirection = Direction.UP;
      ballColor = brickColor;
    } else if (ballY <= -1) {
      ballYDirection = Direction.DOWN;
    }
    if (ballX >= 1) {
      ballXDirection = Direction.LEFT;
    } else if (ballX <= -1) {
      ballXDirection = Direction.RIGHT;
    }
  }

  void moveLeft() {
    if (!(playerX <= -1)) playerX -= 0.025;
    if (!gameHasStarted) ballX = playerX + (playerWidth / 2);
  }

  void moveRight() {
    if (!(playerX + playerWidth >= 1)) playerX += 0.025;
    if (!gameHasStarted) ballX = playerX + (playerWidth / 2);
  }

  void startGame() {
    if (!gameHasStarted) {
      gameHasStarted = true;
      Timer.periodic(Duration(milliseconds: 1), (timer) {
        _timer = timer;
        setState(() {
          updateDirection();
          moveBall();
          // moveEnemy();
          scoreCounter();
          if (isPlayerDead()) {
            _timer?.cancel();
            reSetGame();
          }
        });
      });
    }
  }

  void scoreCounter() {
    double length = SizeConfig.getAlignmentOfScoringObject(30);
    if (ballX < (pointObjectX + length) &&
        ballX > (pointObjectX - length) &&
        ballY < (pointObjectY + length) &&
        ballY > (pointObjectY - length)) {
      if (ballColor == pointObject.color) {
        score++;
        getRandomValuesForScoreObject();
      } else {
        _timer?.cancel();
        reSetGame();
      }
    }
  }

  void moveEnemy() {
    setState(() {
      enemyX = ballX;
    });
  }

  void reSetGame() {
    gameHasStarted = false;
    ballX = 0;
    ballY = 0.84;
    playerX = -0.2;
    enemyX = -0.2;
  }

  bool isPlayerDead() {
    if (ballY >= 1) {
      --life;
      if (life == 0) {
        //TODO: show dialog box and navigate back
        Widget okButton = TextButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.pop(context);
          },
        );

        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: Text("Game Over"),
          content: Text("You are Out"),
          actions: [
            okButton,
          ],
        );

        // show the dialog
        showDialog<AlertDialog>(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
      return true;
    }
    return false;
  }

  void moveBall() {
    if (ballYDirection == Direction.DOWN) {
      ballY += ballSpeedX;
    } else if (ballYDirection == Direction.UP) {
      ballY -= ballSpeedX;
    }

    if (ballXDirection == Direction.LEFT) {
      ballX -= ballSpeedY;
    } else if (ballXDirection == Direction.RIGHT) {
      ballX += ballSpeedY;
    }
  }

  @override
  void initState() {
    super.initState();

    getRandomValuesForScoreObject();
  }

  Offset? previousDetail;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        previousDetail = details.globalPosition;
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (details.globalPosition.dx > previousDetail!.dx) {
          if (details.globalPosition.dx > (previousDetail!.dx + 2)) {
            moveRight();
            previousDetail = details.globalPosition;
          }
        } else {
          if ((details.globalPosition.dx + 2) < previousDetail!.dx) {
            moveLeft();
            previousDetail = details.globalPosition;
          }
        }
        setState(() {});
      },
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
            moveLeft();
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
            moveRight();
          }
          setState(() {});
        },
        child: GestureDetector(
          onTap: startGame,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.grey[900],
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(50),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/coin.png',
                            width: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            score.toString(),
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          )
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                            life,
                            (index) => Image.asset(
                                  'assets/images/heart.png',
                                  width: 20,
                                )),
                      ),
                    ],
                  ),
                ),
              ),
              body: Center(
                child: Stack(
                  children: [
                    CoverScreen(gameHasStarted: gameHasStarted),

                    /*MyBrick(
                      x: enemyX,
                      y: -1,
                      playerWidth: playerWidth,
                      color: Colors.white,
                    ),*/

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
                                      if (!gameHasStarted)
                                        ballColor = selectedColor;
                                    });
                                  },
                                )),
                      ),
                    ),
                    PointObject(
                      gemModel: pointObject,
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
  final GemModel gemModel;
  double height = 20;

  PointObject(
      {Key? key,
      required this.x,
      required this.y,
      required this.width,
      this.height = 20,
      required this.gemModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(x, y),
      child: Image.asset(
        gemModel.path,
        width: 30,
      ),
    );
  }
}

class GemModel {
  final Color color;
  final String path;

  GemModel({required this.color, required this.path});
}
