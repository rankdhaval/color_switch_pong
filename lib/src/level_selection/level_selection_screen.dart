// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:game_template/size_config.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import 'levels.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({Key? key}) : super(key: key);

  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  late BannerAd _bannerAd;

  bool _isBannerAdReady = false;

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-9376762525267033/2535913207',
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _isBannerAdReady
                ? Container(
                    width: AdSize.banner.width.toDouble(),
                    height: AdSize.banner.height.toDouble(),
                    child: AdWidget(ad: _bannerAd),
                  )
                : SizedBox(
                    width: AdSize.banner.width.toDouble(),
                    height: AdSize.banner.height.toDouble(),
                  ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'CHOOSE DIFFICULTY',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: Colors.greenAccent,
                        letterSpacing: 2.5,
                        fontFamily: 'Permanent Marker',
                      ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  for (final level in gameLevels)
                    ListTile(
                      enabled: playerProgress.highestLevelReached >=
                          level.number - 1,
                      onTap: () {
                        final audioController = context.read<AudioController>();
                        audioController.playSfx(SfxType.buttonTap);

                        // GoRouter.of(context)
                        //     .go('/play/session/${level.number}');
                        GoRouter.of(context)
                            .go('/play/gameScreen/${level.number}');
                      },
                      title: Center(
                        child: Text(level.name,
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(
                                  color: (playerProgress.highestLevelReached >=
                                          level.number - 1)
                                      ? Colors.white
                                      : Colors.blueGrey,
                                  letterSpacing: 2.5,
                                  fontFamily: 'Permanent Marker',
                                )),
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
        rectangularMenuArea: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    maximumSize:
                        Size(MediaQuery.of(context).size.width / 2.8, 50),
                    primary: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  GoRouter.of(context).pop();
                },
                child: Text(
                  "BACK",
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: Colors.white,
                        letterSpacing: 2.5,
                        fontFamily: 'Permanent Marker',
                      ),
                )),
          ),
        ),
      ),
    );
  }
}
