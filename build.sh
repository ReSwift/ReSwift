#!/bin/bash

source .build_helpers

update_jazzy \
  https://github.com/agentk/jazzy/ \
  integrated-markdown

generate_docs__org_name_branch \
    ReSwift ReSwift master

