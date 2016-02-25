#!/bin/bash

# ----- Configuration

ORGANISATION=ReSwift
NAME=ReSwift
BRANCH=master
TMP=Docs/tmp

if [ "$OUTPUT_PATH" == "" ]; then
    OUTPUT_PATH=doc_output
fi

# ----- Setup and generate docs

GITHUB=https://github.com/$ORGANISATION/$NAME
URL=http://$ORGANISATION.github.io/$NAME

# Clean $TMP folder
if [ -d "$TMP" ]; then rm -rf "$TMP"; fi
mkdir -p $TMP/{compile,docs,api}

cp Docs/*.md $TMP/api/

# Split the README into sections
./docpreproc README.md "$TMP/docs/About ReSwift.md" --section "About ReSwift" --title "About ReSwift"
./docpreproc README.md "$TMP/docs/Why ReSwift.md" --section "Why ReSwift?" --title "Why ReSwift?"
./docpreproc "Docs/Getting Started Guide.md" "$TMP/docs/Getting Started Guide.md"
./docpreproc README.md "$TMP/docs/Installation.md" --section "Installation" --title "Installation"
./docpreproc README.md "$TMP/docs/Testing.md" --section "Checking out Source Code and Running Tests" --title "Testing"
./docpreproc README.md "$TMP/docs/Demo.md" --section "Demo" --title "Demo"
./docpreproc README.md "$TMP/docs/Extensions.md" --section "Extensions" --title "Extensions"
./docpreproc README.md "$TMP/docs/Example Projects.md" --section "Example Projects" --title "Example Projects"
./docpreproc README.md "$TMP/docs/Contributing.md" --section "Contributing" --title "Contributing"
./docpreproc Changelog.md "$TMP/docs/Changelog.md" --title "Changelog"
./docpreproc README.md "$TMP/docs/Credits.md" --section "Credits" --title "Credits"
./docpreproc README.md "$TMP/docs/Get in touch.md" --section "Get in touch" --title "Credits"
./docpreproc LICENSE.md "$TMP/docs/License.md" --title "License"
./docpreproc README.md "$TMP/compile/intro.md" --section "Intro"

# Generate the landing content
cat Docs/templates/heading.md $TMP/compile/intro.md Docs/templates/toc.md > $TMP/compile/readme-raw.md
./docpreproc "$TMP/compile/readme-raw.md" "$TMP/compile/README.md"
cp $TMP/compile/README.md $TMP/api/Documentation.md

jazzy \
  --config .jazzy.json \
  --clean \
  --output "$OUTPUT_PATH" \
  --module-version "$BRANCH" \
  --dash_url "$URL/$BRANCH/docsets/$NAME.xml" \
  --root-url "$URL/$BRANCH/" \
  --github_url "$GITHUB" \
  --github-file-prefix "$GITHUB/tree/$BRANCH"

cp Docs/img/* $OUTPUT_PATH/img/
