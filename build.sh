#!/bin/bash

# ----- Configuration

JAZZY_REPO=https://github.com/agentk/jazzy/
JAZZY_BRANCH=integrated-markdown

DOCS_REPO=https://github.com/ReSwift/ReSwift.git
DOCS_BRANCH=master
DOCS_NAME=ReSwift

# LATEST_VERSION_TAG=`git ls-remote --tags $DOCS_REPO | awk -F/ '{ print $3 }' | sort -r | grep -E "^\d+.+\d$" | head -n 1`

# ----- Setup and generate docs

source .build_helpers

update_jazzy "$JAZZY_REPO" "$JAZZY_BRANCH"

generate_docs_for_branch "$DOCS_REPO" "$DOCS_BRANCH" "$DOCS_NAME"
cp $DOCS_NAME/Readme/img/* $DOCS_BRANCH/img/