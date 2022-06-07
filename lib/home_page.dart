import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/assets.dart';
import 'package:game_template/score_persistance.dart';
import 'package:game_template/size_config.dart';
import 'package:game_template/src/audio/audio_controller.dart';
import 'package:game_template/src/audio/sounds.dart';
import 'package:game_template/src/level_selection/levels.dart';
import 'package:game_template/src/main_menu/main_menu_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

enum Direction { UP, DOWN, LEFT, RIGHT }

const _gap = SizedBox(height: 10);

class HomePage extends StatefulWidget {
  final GameLevel level;
  const HomePage({super.key, required this.level});
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
  RewardedAd? _rewardedAd;

  late AudioController audioController;

  Timer? _timer;

  //score objrct variable
  GemModel pointObject = GemModel(color: Colors.pink, path: pinkGem);
  double pointObjectHeight = 20;
  double pointObjectWidth = 20;
  double pointObjectX = 20;
  double pointObjectY = 20;

  //ball speed
  double ballSpeedX = 0.002;
  double ballSpeedY = 0.002;

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
      audioController.playSfx(SfxType.hit);
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
        audioController.playSfx(SfxType.congrats);
        score++;
        if (score == widget.level.winScore) {
          GoRouter.of(context).go('/play/won', extra: {'score': score});
        }
        getRandomValuesForScoreObject();
      } else {
        decreaseLife();
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
      decreaseLife();
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

  Future<void> decreaseLife() async {
    audioController.playSfx(SfxType.out);
    --life;
    if (life == 0) {
      //TODO: show dialog box and navigate back

      bool disable2x = false;
      int total = await ScorePersistence().getScore() + score;
      await showDialog<Widget>(
              context: context,
              builder: (context) => PlayerOutDialog(
                    life: life,
                    score: score,
                    totalScore: total,
                    restart: () {
                      audioController.playSfx(SfxType.buttonTap);
                      ScorePersistence().addScore(score);

                      setState(() {
                        score = 0;
                        life = 3;
                      });

                      Navigator.pop(context);
                    },
                    extraLife: () {
                      audioController.playSfx(SfxType.buttonTap);
                      _rewardedAd!.show(onUserEarnedReward:
                          (AdWithoutView ad, RewardItem rewardItem) {
                        // Reward the user for watching an ad.
                        life++;
                        setState(() {});
                        loadRewardedAds();
                      });

                      Navigator.pop(context);
                    },
                    doubleScore: disable2x
                        ? () {}
                        : () {
                            audioController.playSfx(SfxType.buttonTap);
                            _rewardedAd!.show(onUserEarnedReward:
                                (AdWithoutView ad, RewardItem rewardItem) {
                              // Reward the user for watching an ad.
                              score = score * 2;
                              loadRewardedAds();
                              disable2x = true;
                              setState(() {});
                            });
                          },
                  ),
              barrierDismissible: false)
          .then((value) => setState(() {}));
    }
  }

  void loadRewardedAds() {
    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-9376762525267033/8761258820'
            : 'ca-app-pub-3940256099942544/1712485313',
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            this._rewardedAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
          },
        )).then((ad) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) =>
            print('$ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
        },
        onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    ballSpeedX = ballSpeedY = widget.level.ballSpeed;
    loadRewardedAds();
    getRandomValuesForScoreObject();
  }

  Offset? previousDetail;

  @override
  Widget build(BuildContext context) {
    audioController = context.watch<AudioController>();
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
                      Container(
                        width: MediaQuery.of(context).size.width / 4,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Image.asset(
                              jewelGem,
                              width: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              score.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(
                                    color: Colors.white,
                                    letterSpacing: 2.5,
                                    fontFamily: 'Permanent Marker',
                                  ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                              life,
                              (index) => Image.asset(
                                    'assets/images/heart.png',
                                    width: 25,
                                  )),
                        ),
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
      alignment: Alignment(0, 0),
      child: Text(
        gameHasStarted ? "" : "T a p  t o  S t a r t",
        style: Theme.of(context)
            .textTheme
            .headline4!
            .copyWith(color: Colors.white),
      ),
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

class PlayerOutDialog extends StatelessWidget {
  final int life;
  final int score;
  final int totalScore;
  final VoidCallback restart;
  final VoidCallback extraLife;
  final VoidCallback doubleScore;
  PlayerOutDialog(
      {Key? key,
      required this.life,
      required this.score,
      required this.restart,
      required this.extraLife,
      required this.totalScore,
      required this.doubleScore})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Color(0xff122530),
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Your Score",
              style: Theme.of(context).textTheme.headline4!.copyWith(
                    color: Colors.white,
                    letterSpacing: 2.5,
                    fontFamily: 'Permanent Marker',
                  ),
            ),
            _gap,
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    jewelGem,
                    width: 30,
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    'X',
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Colors.white,
                          letterSpacing: 2.5,
                          fontFamily: 'Permanent Marker',
                        ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    '$score',
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                          color: Colors.white,
                          letterSpacing: 2.5,
                          fontFamily: 'Permanent Marker',
                        ),
                  )
                ],
              ),
            ),
            _gap,
            Text(
              'TOTAL SCORE',
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    color: Colors.white,
                    letterSpacing: 2.5,
                    fontFamily: 'Permanent Marker',
                  ),
            ),
            _gap,
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    jewelGem,
                    width: 30,
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    'X',
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Colors.white,
                          letterSpacing: 2.5,
                          fontFamily: 'Permanent Marker',
                        ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    '${totalScore}',
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                          color: Colors.white,
                          letterSpacing: 2.5,
                          fontFamily: 'Permanent Marker',
                        ),
                  )
                ],
              ),
            ),
            _gap,
            CustomElevatedButton(
              color: Colors.blue,
              buttonTitle: 'RESTART',
              onPress: restart,
            ),
            _gap,
            CustomElevatedButton(
              color: Colors.green,
              buttonTitle: 'EXTRA LIFE',
              onPress: extraLife,
            ),
            _gap,
            CustomElevatedButton(
              color: Colors.cyan,
              buttonTitle: '2x REWARD',
              onPress: doubleScore,
            ),
            _gap,
            CustomElevatedButton(
              color: Colors.teal,
              buttonTitle: 'MAIN MENU',
              onPress: () {
                audioController.playSfx(SfxType.buttonTap);
                ScorePersistence().addScore(score);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
