#!/bin/bash

set -e

# Run pod install to fetch the SwiftLint binary
pod install

# Undo all the changes made by CocoaPods
git checkout ReSwift.xcodeproj/project.pbxproj
rm -rf ReSwift.xcworkspace
