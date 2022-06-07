// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game_template/score_persistance.dart';
import 'package:game_template/src/audio/audio_controller.dart';
import 'package:game_template/src/audio/sounds.dart';
import 'package:game_template/src/main_menu/main_menu_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../assets.dart';
import '../ads/ads_controller.dart';
import '../ads/banner_ad_widget.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class WinGameScreen extends StatelessWidget {
  /* Score*/ int score;

  WinGameScreen({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final adsControllerAvailable = context.watch<AdsController?>() != null;
    final adsRemoved =
        context.watch<InAppPurchaseController?>()?.adRemoval.active ?? false;
    final palette = context.watch<Palette>();
    final audioController = context.watch<AudioController>();

    const gap = SizedBox(height: 10);
    ScorePersistence().addScore(score);
    final totalScore = ScorePersistence().getScore();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (adsControllerAvailable && !adsRemoved) ...[
              const Expanded(
                child: Center(
                  child: BannerAdWidget(),
                ),
              ),
            ],
            gap,
            const Center(
              child: Text(
                'You won!',
                style: TextStyle(
                    fontFamily: 'Permanent Marker',
                    fontSize: 50,
                    color: Colors.green),
              ),
            ),
            gap,
            Text(
              "Your Score",
              style: Theme.of(context).textTheme.headline4!.copyWith(
                    color: Colors.white,
                    letterSpacing: 2.5,
                    fontFamily: 'Permanent Marker',
                  ),
            ),
            gap,
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
            gap,
            CustomElevatedButton(
              color: Colors.blue,
              buttonTitle: 'RESTART',
              onPress: () {
                GoRouter.of(context).pop();
              },
            ),
            gap,
            CustomElevatedButton(
              color: Colors.cyan,
              buttonTitle: '2x REWARD',
              onPress: () {
                loadRewardedAds();
                audioController.playSfx(SfxType.buttonTap);
                _rewardedAd!.show(onUserEarnedReward:
                    (AdWithoutView ad, RewardItem rewardItem) {
                  ScorePersistence().addScore(score);
                  score *= 2;
                  GoRouter.of(context).pop();
                });
              },
            ),
          ],
        ),
        rectangularMenuArea: CustomElevatedButton(
          color: Colors.teal,
          buttonTitle: 'MAIN MENU',
          onPress: () {
            audioController.playSfx(SfxType.buttonTap);
            GoRouter.of(context).pop();
          },
        ),
      ),
    );
  }

  RewardedAd? _rewardedAd;

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
}
