#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="TopMemo"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
FRAMEWORKS_DIR="$CONTENTS_DIR/Frameworks"
EXECUTABLE="$MACOS_DIR/$APP_NAME"
ARCH="$(uname -m)"
TARGET="$ARCH-apple-macos13.0"
MODULE_CACHE_DIR="$BUILD_DIR/ModuleCache"
SDK_MODULE_CACHE_DIR="$BUILD_DIR/SDKModuleCache"
SOURCE_FILES=("${(@f)$(find "$ROOT_DIR/TopMemo" -name '*.swift' | sort)}")

if [[ ${#SOURCE_FILES[@]} -eq 0 ]]; then
    echo "No Swift source files found." >&2
    exit 1
fi

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$FRAMEWORKS_DIR" "$MODULE_CACHE_DIR" "$SDK_MODULE_CACHE_DIR"
cp "$ROOT_DIR/Distribution/Info.plist" "$CONTENTS_DIR/Info.plist"

xcrun swiftc \
    -target "$TARGET" \
    -parse-as-library \
    -module-cache-path "$MODULE_CACHE_DIR" \
    -sdk-module-cache-path "$SDK_MODULE_CACHE_DIR" \
    -O \
    -framework SwiftUI \
    -framework AppKit \
    -framework Combine \
    "${SOURCE_FILES[@]}" \
    -o "$EXECUTABLE"

xcrun swift-stdlib-tool \
    --copy \
    --platform macosx \
    --scan-executable "$EXECUTABLE" \
    --destination "$FRAMEWORKS_DIR"

codesign --force --deep --sign - "$APP_DIR" >/dev/null

echo "$APP_DIR"
