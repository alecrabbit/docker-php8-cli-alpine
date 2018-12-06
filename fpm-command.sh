#!/usr/bin/env bash
FILE="/usr/local/etc/php/conf.d/pthreads.ini";
if [ -e $FILE ]
then
  rm "${FILE}"
fi

php-fpm "$@"
