// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

const gameLevels = [
  GameLevel(
    number: 1,
    difficulty: 1,
    ballSpeed: 0.0016,
    name: "LEVEL 1",
    winScore: 21,
    lifeTimerSeconds: 0,
    superBallActivateTimerSeconds: 0,
    superBallTimerSeconds: 0,
    scoreIntervalForShowLife: 0,
    scoreIntervalForSuperBall: 0,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 2,
    difficulty: 1,
    ballSpeed: 0.0017,
    name: "LEVEL 2",
    winScore: 25,
    lifeTimerSeconds: 0,
    superBallActivateTimerSeconds: 0,
    superBallTimerSeconds: 0,
    scoreIntervalForShowLife: 0,
    scoreIntervalForSuperBall: 0,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 3,
    difficulty: 1,
    ballSpeed: 0.0018,
    name: "LEVEL 3",
    winScore: 30,
    lifeTimerSeconds: 45,
    scoreIntervalForShowLife: 10,
    superBallActivateTimerSeconds: 0,
    superBallTimerSeconds: 0,
    scoreIntervalForSuperBall: 0,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 4,
    difficulty: 4,
    ballSpeed: 0.0019,
    name: "LEVEL 4",
    winScore: 35,
    lifeTimerSeconds: 40,
    scoreIntervalForShowLife: 11,
    superBallActivateTimerSeconds: 0,
    superBallTimerSeconds: 0,
    scoreIntervalForSuperBall: 0,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 5,
    difficulty: 5,
    ballSpeed: 0.0020,
    name: "LEVEL 5",
    winScore: 35,
    lifeTimerSeconds: 40,
    scoreIntervalForShowLife: 15,
    superBallActivateTimerSeconds: 0,
    superBallTimerSeconds: 0,
    scoreIntervalForSuperBall: 0,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 6,
    difficulty: 6,
    ballSpeed: 0.0021,
    name: "LEVEL 6",
    winScore: 50,
    lifeTimerSeconds: 30,
    scoreIntervalForShowLife: 20,
    superBallActivateTimerSeconds: 90,
    superBallTimerSeconds: 45,
    scoreIntervalForSuperBall: 15,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 7,
    difficulty: 7,
    ballSpeed: 0.0022,
    name: "LEVEL 7",
    winScore: 50,
    lifeTimerSeconds: 30,
    scoreIntervalForShowLife: 20,
    superBallActivateTimerSeconds: 80,
    superBallTimerSeconds: 40,
    scoreIntervalForSuperBall: 15,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 8,
    difficulty: 8,
    ballSpeed: 0.0023,
    name: "LEVEL 8",
    winScore: 50,
    lifeTimerSeconds: 30,
    scoreIntervalForShowLife: 20,
    superBallActivateTimerSeconds: 75,
    superBallTimerSeconds: 40,
    scoreIntervalForSuperBall: 15,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 9,
    difficulty: 9,
    ballSpeed: 0.0024,
    name: "LEVEL 9",
    winScore: 51,
    lifeTimerSeconds: 30,
    scoreIntervalForShowLife: 25,
    superBallActivateTimerSeconds: 70,
    superBallTimerSeconds: 40,
    scoreIntervalForSuperBall: 16,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 10,
    difficulty: 10,
    ballSpeed: 0.0025,
    name: "LEVEL 10",
    winScore: 51,
    lifeTimerSeconds: 30,
    scoreIntervalForShowLife: 25,
    superBallActivateTimerSeconds: 70,
    superBallTimerSeconds: 40,
    scoreIntervalForSuperBall: 16,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 11,
    difficulty: 11,
    ballSpeed: 0.0025,
    name: "LEVEL 11",
    winScore: 101,
    lifeTimerSeconds: 30,
    scoreIntervalForShowLife: 25,
    superBallActivateTimerSeconds: 70,
    superBallTimerSeconds: 40,
    scoreIntervalForSuperBall: 16,
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
];

class GameLevel {
  final int number;

  final int difficulty;

  final double ballSpeed;

  final String name;

  final int winScore;

  final int lifeTimerSeconds;

  final int superBallTimerSeconds;

  final int superBallActivateTimerSeconds;

  final int scoreIntervalForShowLife;

  final int scoreIntervalForSuperBall;

  /// The achievement to unlock when the level is finished, if any.
  final String? achievementIdIOS;

  final String? achievementIdAndroid;

  bool get awardsAchievement => achievementIdAndroid != null;

  const GameLevel({
    required this.lifeTimerSeconds,
    required this.superBallTimerSeconds,
    required this.superBallActivateTimerSeconds,
    required this.scoreIntervalForShowLife,
    required this.scoreIntervalForSuperBall,
    required this.number,
    required this.difficulty,
    required this.name,
    required this.ballSpeed,
    required this.winScore,
    this.achievementIdIOS,
    this.achievementIdAndroid,
  }) : assert(
            (achievementIdAndroid != null && achievementIdIOS != null) ||
                (achievementIdAndroid == null && achievementIdIOS == null),
            'Either both iOS and Android achievement ID must be provided, '
            'or none');
}
