// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

List<String> soundTypeToFilename(SfxType type) {
  switch (type) {
    case SfxType.hit:
      return const ['hit.wav'];
    case SfxType.buttonTap:
      return const ['buttonClick.wav'];
    case SfxType.congrats:
      return const ['reward.wav'];
    case SfxType.out:
      return const ['out.wav'];
  }
}

/// Allows control over loudness of different SFX types.
double soundTypeToVolume(SfxType type) {
  switch (type) {
    case SfxType.buttonTap:
      return 1.0;
    case SfxType.congrats:
      return 1.0;
    case SfxType.hit:
      return 0.7;
    case SfxType.out:
      return 1.0;
  }
}

enum SfxType { hit, buttonTap, congrats, out }
