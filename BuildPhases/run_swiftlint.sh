#!/bin/bash

set -e

swiftlint=$SRCROOT/Pods/SwiftLint/swiftlint

if [ -f $swiftlint ]; then
  $swiftlint
else
  echo 'warning: Cannot find SwiftLint in the expected location. If you are developing ReSwift please install it via using `./Scripts/install_swiftlint.sh`. If you are building ReSwift as a dependency of your project feel free to ignore this.'
fi
