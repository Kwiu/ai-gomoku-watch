# AI 五子棋 for Apple Watch

An offline 11 x 11 Gomoku game with a lightweight heuristic AI, adaptive
SwiftUI layout for Apple Watch Series 9, haptics, win detection, and restart.

## Build on macOS

The GitHub Actions `Build Watch App` workflow runs on the public `xcode-27`
runner, verifies the game core, and uploads both a standalone Watch bundle and
an unsigned IPA with an iPhone host plus the embedded Watch companion.

For a local build:

```sh
brew install xcodegen
xcodegen generate
xcodebuild -project AIGomoku.xcodeproj -scheme AIGomoku \
  -sdk watchos -destination "generic/platform=watchOS" \
  CODE_SIGNING_ALLOWED=NO build
```

## Build with xtool

On Windows/WSL, after installing the watchOS SDK:

```sh
cd /mnt/c/Users/Kivv/Documents/ChatGPT/watch/watch-gomoku
xtool dev build --triple arm64-apple-watchos
```
