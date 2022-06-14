import 'package:flutter/material.dart';
import 'package:game_template/src/settings/settings.dart';
import 'package:game_template/src/style/palette.dart';
import 'package:provider/provider.dart';

class Achievements extends StatefulWidget {
  const Achievements({super.key});

  @override
  _AchievementsState createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: ListView(
        children: [
          _gap,
          Text(
            'Settings',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline3!.copyWith(
                fontFamily: 'Permanent Marker',
                letterSpacing: 2.0,
                color: palette.whitePen),
          ),
          _gap,
        ],
      ),
    );
  }
}
