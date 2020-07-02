#!/usr/bin/env bash

if [[ $(which code-insiders) && ! $(which code) ]]; then
  GIT_ED="code-insiders"
else
  GIT_ED="code"
fi

$GIT_ED --wait $@

