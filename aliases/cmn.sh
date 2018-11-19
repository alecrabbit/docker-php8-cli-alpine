#!/usr/bin/env bash
if [ -z ${1} ]
then
  echo "No filename provided"
  exit 1
fi

APP_DIR="${APP_DIR:-/var/www}";
FILE="$APP_DIR/vendor/bin/${1}";

if [ -e $FILE ]
then
  PATH = $FILE
fi

APP_DIR="${APP_DIR:-/tmp}";
FILE="$APP_DIR/vendor/bin/${1}";

if [ -e $FILE ]
then
  PATH = $FILE
fi

if [ -z $PATH ]
then
  echo "It seems like ${1} is not installed. Search path was: ${FILE}"
else
  ${1}
fi

echo ${PATH}
