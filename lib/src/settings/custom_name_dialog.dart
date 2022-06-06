// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_template/src/settings/settings.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';

void showCustomNameDialog(BuildContext context) {
  showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          CustomNameDialog(animation: animation));
}

class CustomNameDialog extends StatefulWidget {
  final Animation<double> animation;

  const CustomNameDialog({required this.animation, super.key});

  @override
  State<CustomNameDialog> createState() => _CustomNameDialogState();
}

class _CustomNameDialogState extends State<CustomNameDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: widget.animation,
        curve: Curves.easeOutCubic,
      ),
      child: SimpleDialog(
        title: Text(
          'Change name',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
              fontFamily: 'Permanent Marker',
              letterSpacing: 2.0,
              color: palette.whitePen),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Color(0xff122530),
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 12,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontFamily: 'Permanent Marker',
                letterSpacing: 2.0,
                color: palette.whitePen),
            onChanged: (value) {
              context.read<SettingsController>().setPlayerName(value);
            },
            onSubmitted: (value) {
              // Player tapped 'Submit'/'Done' on their keyboard.
              Navigator.pop(context);
            },
          ),
          SizedBox(
            width: 300,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(300, 30),
                    primary: Colors.cyan,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "DONE",
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: Colors.white,
                        letterSpacing: 2.5,
                        fontFamily: 'Permanent Marker',
                      ),
                )),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    _controller.text = context.read<SettingsController>().playerName.value;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
