#! /usr/bin/env bash

# Open chrome with insecure certificate settings.

readonly PROGNAME=$(basename "$0")

case $(uname -s) in
Darwin)
    open -a "Google Chrome" --args --ignore-certificate-errors
    ;;
*)
    printf "%s: unsupported platform '%s'\n" "$PROGNAME" "$(uname -s)"
    exit 2
    ;;
esac
