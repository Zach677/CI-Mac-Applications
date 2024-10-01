#!/bin/bash

set -e
set -o pipefail

VERSION_FILE="ProcessReporter.xcodeproj/project.pbxproj"
VERSION=$(grep -m1 "MARKETING_VERSION =" "$VERSION_FILE" | sed -E 's/.*MARKETING_VERSION = (([0-9]+\.){2}[0-9]+).*/\1/')
VERSION_MAJOR=$(echo $VERSION | cut -d. -f1)
VERSION_MINOR=$(echo $VERSION | cut -d. -f2)
VERSION_PATCH=$(echo $VERSION | cut -d. -f3)

echo "[*] reading version $VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"

if [ -n "$CI_SKIP_BUMP_VERSION" ]; then
    echo "[*] environment variable indicates to skip bumping version"
else
    echo "[*] bumping version..."
    VERSION_PATCH=$((VERSION_PATCH + 1))
    if [ "$CONFIGURATION" = "Release" ]; then
        VERSION_MINOR=$((VERSION_MINOR + 1))
    fi
    NEW_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"
    echo "[*] will update version to $NEW_VERSION"
    sed -i '' "s/MARKETING_VERSION = $VERSION/MARKETING_VERSION = $NEW_VERSION/g" "$VERSION_FILE"
fi

if [ -n "$CODESIGNING_FOLDER_PATH" ]; then
    echo "[*] updating Info.plist"
    INFO_PLIST="$CODESIGNING_FOLDER_PATH/Contents/Info.plist"

    echo "[*] updating CFBundleShortVersionString to $VERSION_MAJOR.$VERSION_MINOR"
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION_MAJOR.$VERSION_MINOR" "$INFO_PLIST"

    echo "[*] updating CFBundleVersion to $VERSION_PATCH"
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION_PATCH" "$INFO_PLIST"
fi

echo "[*] done $0"