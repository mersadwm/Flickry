#!/bin/sh

if which swiftlint >/dev/null; then
    swiftlint lint --config $SRCROOT/Scripts/.swiftlint.yml
    swiftlint
else
echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi

