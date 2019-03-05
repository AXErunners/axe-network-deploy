#!/usr/bin/env bash

scripts=("deploy destroy test list logs axe-cli")

if [[ " ${scripts[@]} " =~ " ${1} " ]]; then
    script=$1

    # Remove the first argument ("axe-network")
    shift

    source "bin/$script"
else
    exec "$@"
fi
