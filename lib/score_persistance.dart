// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

/// An implementation of [SettingsPersistence] that uses
/// `package:shared_preferences`.
class ScorePersistence {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  Future<void> addScore(int value) async {
    final prefs = await instanceFuture;
    await prefs.setInt('Score', (prefs.getInt('Score') ?? 0) + value);
  }

  Future<int> getScore() async {
    final prefs = await instanceFuture;
    return prefs.getInt('Score') ?? 0;
  }

  Future<bool> getFirstTime() async {
    final prefs = await instanceFuture;
    return prefs.getBool('FirstTime') ?? true;
  }

  Future<void> setFirstTime() async {
    final prefs = await instanceFuture;
    await prefs.setBool('FirstTime', false);
  }
}
