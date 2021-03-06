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
import 'package:game_template/src/player_progress/player_progress.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
  double ballY = 0.940;
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

  //widget keys
  GlobalKey brickKey = GlobalKey();
  GlobalKey superBallKey = GlobalKey();
  GlobalKey colorChangerKey = GlobalKey();
  GlobalKey ballKey = GlobalKey();
  GlobalKey gemKey = GlobalKey();
  GlobalKey scoreKey = GlobalKey();
  GlobalKey lifeKey = GlobalKey();

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

  double lifeX = 0;
  double lifeY = 0;
  bool lifeVisibility = false;
  Timer? lifeTimer;
  void getPositionForExtraLife() {
    final _random = Random();
    setState(() {
      bool xval = _random.nextBool();
      lifeX = (_random.nextInt(10) / 15) * (xval == true ? 1 : -1);
      bool yval = _random.nextBool();
      lifeY = (_random.nextInt(10) / 30) * (yval == true ? 1 : -1);
    });
    lifeTimer = Timer(
      Duration(seconds: widget.level.lifeTimerSeconds),
      () {
        setState(() {
          lifeVisibility = false;
        });
      },
    );
  }

  double superCollectorBallX = 0;
  double superCollectorBallY = 0;
  bool superCollectorBallVisibility = false;
  bool superCollectorBallActivate = false;
  Timer? superCollectorBallTimer;
  Timer? superCollectorBallActiveTimer;
  void getPositionForSuperBall() {
    final _random = Random();
    setState(() {
      bool xval = _random.nextBool();
      superCollectorBallX =
          (_random.nextInt(10) / 15) * (xval == true ? 1 : -1);
      bool yval = _random.nextBool();
      superCollectorBallY =
          (_random.nextInt(10) / 30) * (yval == true ? 1 : -1);
    });
    superCollectorBallTimer = Timer(
      Duration(seconds: widget.level.superBallTimerSeconds),
      () {
        setState(() {
          superCollectorBallVisibility = false;
        });
      },
    );
  }

/*  double ballMultiplierX = 0;
  double ballMultiplierY = 0;

  void getBallMultiplier(){
    final _random = Random();
    setState(() {
      bool xval = _random.nextBool();
      ballMultiplierX = (_random.nextInt(10) / 15) * (xval == true ? 1 : -1);
      bool yval = _random.nextBool();
      ballMultiplierY = (_random.nextInt(10) / 30) * (yval == true ? 1 : -1);
    });
    lifeTimer = Timer(
      Duration(seconds: 30),
          () {
        setState(() {
          lifeVisibility = false;
        });
      },
    );
  }*/

  void updateDirection() {
    if (ballY >= 0.96 && playerX + playerWidth >= ballX && playerX <= ballX) {
      audioController.playSfx(SfxType.hit);
      ballYDirection = Direction.UP;
      if (!superCollectorBallActivate) ballColor = brickColor;
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
      if (ballColor == pointObject.color || superCollectorBallActivate) {
        getRandomValuesForScoreObject();
        audioController.playSfx(SfxType.congrats);
        score++;
        print("====================== $score");
        if (score == widget.level.winScore) {
          final playerProgress = context.read<PlayerProgress>();
          playerProgress.setLevelReached(widget.level.number);
          GoRouter.of(context).go('/play/won', extra: {'score': score});
        }
        if (score % widget.level.scoreIntervalForShowLife == 0) {
          lifeVisibility = true;
          getPositionForExtraLife();
        } else if (score % widget.level.superBallActivateTimerSeconds == 0) {
          superCollectorBallVisibility = true;
          getPositionForSuperBall();
        }
      } else {
        decreaseLife();
        _timer?.cancel();
        reSetGame();
      }
    } else if (ballX < (lifeX + length) &&
        ballX > (lifeX - length) &&
        ballY < (lifeY + length) &&
        ballY > (lifeY - length) &&
        lifeVisibility == true) {
      if (life < 5) {
        life++;
        lifeTimer?.cancel();
        lifeVisibility = false;
      }
    } else if (ballX < (superCollectorBallX + length) &&
        ballX > (superCollectorBallX - length) &&
        ballY < (superCollectorBallY + length) &&
        ballY > (superCollectorBallY - length) &&
        superCollectorBallVisibility == true) {
      ballColor = Colors.white;
      superCollectorBallVisibility = false;
      superCollectorBallActivate = true;
      superCollectorBallActiveTimer = Timer(
          Duration(seconds: widget.level.superBallActivateTimerSeconds), () {
        superCollectorBallActivate = false;
        ballColor = brickColor;
      });
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
    ballY = 0.945;
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
    ballXDirection = Direction.LEFT;
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
                    winScore: widget.level.winScore,
                    restart: () {
                      audioController.playSfx(SfxType.buttonTap);
                      ScorePersistence().addScore(score);

                      _rewardedInterstitialAd?.show(
                          onUserEarnedReward:
                              (AdWithoutView ad, RewardItem rewardItem) {});

                      loadRewardedInterstrial();

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
      _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
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

  RewardedInterstitialAd? _rewardedInterstitialAd;
  void loadRewardedInterstrial() {
    RewardedInterstitialAd.load(
        adUnitId: 'ca-app-pub-9376762525267033/6824149171',
        request: AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            print('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            this._rewardedInterstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedInterstitialAd failed to load: $error');
          },
        )).then((value) {
      _rewardedInterstitialAd?.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
            print('$ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
          print('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent:
            (RewardedInterstitialAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
        },
        onAdImpression: (RewardedInterstitialAd ad) =>
            print('$ad impression occurred.'),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    ballSpeedX = ballSpeedY = widget.level.ballSpeed;
    loadRewardedAds();
    loadRewardedInterstrial();
    getRandomValuesForScoreObject();
    targetsDecisionMethod();
  }

  Future<void> targetsDecisionMethod() async {
    if (await ScorePersistence().getFirstTime()) {
      addTargets();
      Future.delayed(Duration.zero, showTutorial);
      await ScorePersistence().setFirstTime();
    }
  }

  List<TargetFocus> targets = [];
  void addTargets() {
    targets.add(TargetFocus(
        identify: "Target 1",
        keyTarget: colorChangerKey,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      "Change Color",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Select Color to change the color of brick and ball. when you select color bricks color will be selected color.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ))
        ]));

    targets
        .add(TargetFocus(identify: "Target 2", keyTarget: brickKey, contents: [
      TargetContent(
          align: ContentAlign.top,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "bounce ball",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "when ball hits the brick color of ball would be changes as brick.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ]));

    targets
        .add(TargetFocus(identify: "Target 3", keyTarget: ballKey, contents: [
      TargetContent(
          align: ContentAlign.top,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "ball",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "when gem color ball touches to gem you will get the point",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ]));

    targets.add(TargetFocus(identify: "Target 4", keyTarget: gemKey, contents: [
      TargetContent(
          align: ContentAlign.top,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Gem",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Ball touches gem you get point",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ]));

    targets
        .add(TargetFocus(identify: "Target 5", keyTarget: scoreKey, contents: [
      TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Score",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Your Score will Displayed Here",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ]));

    targets
        .add(TargetFocus(identify: "Target 6", keyTarget: lifeKey, contents: [
      TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Lifes",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Your Remaining lifes will be shown here",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ]));
  }

  void showTutorial() {
    TutorialCoachMark(
      context,
      targets: targets, // List<TargetFocus>
      colorShadow: Colors.black, // DEFAULT Colors.black

      // alignSkip: Alignment.bottomRight,
      // textSkip: "SKIP",
      // paddingFocus: 10,
      opacityShadow: 0.6,
      onClickTarget: (target) {
        print(target);
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print(target);
      },
      onSkip: () {
        print("skip");
      },
      onFinish: () {
        print("finish");
      },
    ).show();
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
                        key: scoreKey,
                        width: MediaQuery.of(context).size.width / 2.5,
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
                              '${score} / ${widget.level.winScore}',
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
                        key: lifeKey,
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
                      key: brickKey,
                      x: playerX,
                      y: 1,
                      playerWidth: playerWidth,
                      color: brickColor,
                    ),
                    MyBall(
                      key: ballKey,
                      x: ballX,
                      y: ballY,
                      myBallColor: ballColor,
                    ),
                    PointObject(
                      key: gemKey,
                      gemModel: pointObject,
                      width: pointObjectWidth,
                      height: pointObjectHeight,
                      x: pointObjectX,
                      y: pointObjectY,
                    ),
                    Visibility(
                        visible: lifeVisibility,
                        child: ExtraLife(
                          x: lifeX,
                          y: lifeY,
                          width: pointObjectWidth,
                          height: pointObjectHeight,
                        )),
                    Visibility(
                        visible: superCollectorBallVisibility,
                        child: MyBall(
                          key: superBallKey,
                          x: superCollectorBallX,
                          y: superCollectorBallY,
                          myBallColor: Colors.white,
                        ))
                  ],
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                      colors.length,
                      (index) => ColorOptions(
                            key: index == 1 ? colorChangerKey : null,
                            color: colors[index],
                            selected: selectedColor == colors[index],
                            onTap: () {
                              setState(() {
                                selectedColor = colors[index];
                                brickColor = selectedColor;
                                if (!gameHasStarted) ballColor = selectedColor;
                              });
                            },
                          )),
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
  final Key? key;
  final Color color;
  final bool selected;

  const ColorOptions(
      {required this.onTap,
      required this.color,
      required this.selected,
      this.key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: key,
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: selected ? Border.all(width: 3, color: Colors.white) : null,
            shape: BoxShape.circle,
            color: color),
      ),
    );
  }
}

class MyBrick extends StatelessWidget {
  final Key key;
  final double x;
  final double y;
  final double playerWidth;
  final Color color;

  MyBrick(
      {required this.x,
      required this.y,
      required this.playerWidth,
      required this.color,
      required this.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment((2 * x + playerWidth) / (2 - playerWidth), y),
      child: ClipRRect(
        key: key,
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
  final Key key;
  final double x;
  final double y;
  final Color myBallColor;

  MyBall(
      {required this.x,
      required this.y,
      required this.myBallColor,
      required this.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(x, y),
      child: Container(
        key: key,
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
  final Key key;
  final double x;
  final double y;
  final double width;
  final GemModel gemModel;
  double height = 20;

  PointObject(
      {required this.key,
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
        key: key,
        gemModel.path,
        width: 30,
      ),
    );
  }
}

class ExtraLife extends StatelessWidget {
  final double x;
  final double y;
  final double width;
  double height = 20;

  ExtraLife({
    Key? key,
    required this.x,
    required this.y,
    required this.width,
    this.height = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(x, y),
      child: Image.asset(
        lifeGem,
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
  final int winScore;
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
      required this.doubleScore,
      required this.winScore})
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
                  /*Text(
                    'X',
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Colors.white,
                          letterSpacing: 2.5,
                          fontFamily: 'Permanent Marker',
                        ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),*/
                  Text(
                    '$score / $winScore',
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
                  /*const SizedBox(
                    width: 7,
                  ),
                  Text(
                    'X',
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Colors.white,
                          letterSpacing: 2.5,
                          fontFamily: 'Permanent Marker',
                        ),
                  ),*/
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
