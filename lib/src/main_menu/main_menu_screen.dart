// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../size_config.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../games_services/games_services.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
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
    SizeConfig().init(context);
    final palette = context.watch<Palette>();
    final gamesServicesController = context.watch<GamesServicesController?>();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: ResponsiveScreen(
        mainAreaProminence: 0.45,
        squarishMainArea: Center(
          child: Text(
            'COLOR SWITCH PONG',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Permanent Marker',
              fontSize: 55,
              letterSpacing: 2.5,
              color: palette.whitePen,
              height: 1,
            ),
          ),
        ),
        rectangularMenuArea: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomElevatedButton(
              color: Colors.green,
              buttonTitle: 'PLAY',
              onPress: () {
                audioController.playSfx(SfxType.buttonTap);

                GoRouter.of(context).go('/gameScreen');
              },
            ),
            /*ElevatedButton(
              onPressed: () {
                audioController.playSfx(SfxType.buttonTap);

                GoRouter.of(context).go('/gameScreen');
              },
              child: const Text('Play'),
            ),*/
            _gap,
            if (gamesServicesController != null) ...[
              _hideUntilReady(
                ready: gamesServicesController.signedIn,
                child: ElevatedButton(
                  onPressed: () => gamesServicesController.showAchievements(),
                  child: const Text('Achievements'),
                ),
              ),
              _gap,
              _hideUntilReady(
                ready: gamesServicesController.signedIn,
                child: ElevatedButton(
                  onPressed: () => gamesServicesController.showLeaderboard(),
                  child: const Text('Leaderboard'),
                ),
              ),
              _gap,
            ],
            CustomElevatedButton(
                color: Colors.cyan,
                buttonTitle: 'Settings',
                onPress: () {
                  audioController.playSfx(SfxType.buttonTap);
                  GoRouter.of(context).go('/settings');
                }),
            /*ElevatedButton(
              onPressed: () => GoRouter.of(context).go('/settings'),
              child: const Text('Settings'),
            ),*/
            _gap,
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: ValueListenableBuilder<bool>(
                valueListenable: settingsController.muted,
                builder: (context, muted, child) {
                  return IconButton(
                    onPressed: () => settingsController.toggleMuted(),
                    icon: Icon(muted ? Icons.volume_off : Icons.volume_up),
                  );
                },
              ),
            ),
            _gap,
            const Text('Music by Mr Smith'),
            _gap,
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
          ],
        ),
      ),
    );
  }

  /// Prevents the game from showing game-services-related menu items
  /// until we're sure the player is signed in.
  ///
  /// This normally happens immediately after game start, so players will not
  /// see any flash. The exception is folks who decline to use Game Center
  /// or Google Play Game Services, or who haven't yet set it up.
  Widget _hideUntilReady({required Widget child, required Future<bool> ready}) {
    return FutureBuilder<bool>(
      future: ready,
      builder: (context, snapshot) {
        // Use Visibility here so that we have the space for the buttons
        // ready.
        return Visibility(
          visible: snapshot.data ?? false,
          maintainState: true,
          maintainSize: true,
          maintainAnimation: true,
          child: child,
        );
      },
    );
  }

  static const _gap = SizedBox(height: 10);
}

class CustomElevatedButton extends StatelessWidget {
  final Color color;
  final String buttonTitle;
  final VoidCallback onPress;
  const CustomElevatedButton(
      {Key? key,
      required this.color,
      required this.buttonTitle,
      required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: Size(MediaQuery.of(context).size.width / 2.8, 50),
            primary: color,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: palette.whitePen, width: 2),
                borderRadius: BorderRadius.circular(20))),
        onPressed: onPress,
        child: Text(
          buttonTitle,
          style: Theme.of(context).textTheme.headline5!.copyWith(
                color: Colors.white,
                letterSpacing: 2.5,
                fontFamily: 'Permanent Marker',
              ),
        ));
  }
}
