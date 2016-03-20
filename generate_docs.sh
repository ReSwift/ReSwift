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
./docpreproc README.md "$TMP/docs/Installation.md" --section "Installation" --title "Installation"
./docpreproc README.md "$TMP/docs/Checking out Source Code.md" --section "Checking out Source Code" --title "Checking out Source Code"
./docpreproc README.md "$TMP/docs/Demo.md" --section "Demo" --title "Demo"
./docpreproc README.md "$TMP/docs/Extensions.md" --section "Extensions" --title "Extensions"
./docpreproc README.md "$TMP/docs/Example Projects.md" --section "Example Projects" --title "Example Projects"
./docpreproc README.md "$TMP/docs/Credits.md" --section "Credits" --title "Credits"
./docpreproc README.md "$TMP/docs/Get in touch.md" --section "Get in touch" --title "Get in touch"
./docpreproc README.md "$TMP/compile/intro.md" --section "Introduction"

# Copy remaining root docs
./docpreproc CONTRIBUTING.md "$TMP/docs/Contributing.md"
./docpreproc CHANGELOG.md "$TMP/docs/Changelog.md" --title "Changelog"
./docpreproc LICENSE.md "$TMP/docs/License.md" --title "License"

# Copy over the Getting started guide
./docpreproc "Docs/Getting Started Guide.md" "$TMP/docs/Getting Started Guide.md"

# Create the documentation landing page by combining:
#
# - Docs/templates/heading.md
# - README.md#introduction
# - Docs/templates/toc.md
#
cat Docs/templates/heading.md $TMP/compile/intro.md Docs/templates/toc.md > $TMP/compile/readme-raw.md
./docpreproc "$TMP/compile/readme-raw.md" "$TMP/compile/README.md"
cp $TMP/compile/README.md $TMP/api/Documentation.md

# Compile our Docs/tmp + generate API docs using jazzy
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
