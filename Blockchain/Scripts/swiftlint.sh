#!/bin/sh
#
#  Blockchain/Scripts/swiftlint.sh
#
#  What It Does
#  ------------
#  Runs swiftlint if it is available.

if [[ ! -z "${SKIP_SWIFTLINT}" && "${SKIP_SWIFTLINT}" == true ]]; then
    exit 0
fi

if [[ ! -z "${IS_CI}" && "${IS_CI}" == true ]]; then
    echo "warning: running on CI, skipping swiftlint check"
    exit 0
fi

if which swiftlint > /dev/null; then
    swiftlint --quiet
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
