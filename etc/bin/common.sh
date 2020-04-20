#!/usr/bin/env bash
if [ -z ${1} ]
then
  echo "No filename provided"
  exit 1
fi

APP_DIR="${APP_DIR:-/var/www}";
COMPOSER_HOME="${COMPOSER_HOME:-/tmp/composer}";
SEARCH_PATH=''

FILE="$APP_DIR/vendor/bin/${1}";
if [ -e $FILE ]
then
  NEWPATH=$FILE
else
  SEARCH_PATH="${SEARCH_PATH}\n${FILE}"
fi

FILE="$COMPOSER_HOME/vendor/bin/${1}";
if [ -e $FILE ]
then
  NEWPATH=$FILE
else
  SEARCH_PATH="${SEARCH_PATH}\n${FILE}"
fi

if [ -z $NEWPATH ]
then
  echo -e "It seems like '${1}' is not installed(Wrong container?).\nSearch paths was: ${SEARCH_PATH}"
  exit 1
else
  shift
  ${NEWPATH} "$@"
fi
