#!/usr/bin/env bash

# Unminimize documentation
if type unminimize >/dev/null 2>&1; then
    yes | unminimize 2>&1
fi