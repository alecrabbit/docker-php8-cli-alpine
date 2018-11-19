#!/usr/bin/env bash
if [ -z ${1} ]
then
  echo "No filename provided"
  exit 1
fi

APP_DIR="${APP_DIR:-/var/www}";
TMP_DIR="${TMP_DIR:-/tmp}";
SEARCH_PATH=''

FILE="$APP_DIR/vendor/bin/${1}";
if [ -e $FILE ]
then
  NEWPATH=$FILE
else
  SEARCH_PATH="${SEARCH_PATH} ${FILE}"
fi

FILE="$TMP_DIR/vendor/bin/${1}";
if [ -e $FILE ]
then
  NEWPATH=$FILE
else
  SEARCH_PATH="${SEARCH_PATH} ${FILE}"
fi

if [ -z $NEWPATH ]
then
  echo "It seems like ${1} is not installed. Search path was: ${SEARCH_PATH}"
else
  shift
  ${NEWPATH} "$@"
fi
