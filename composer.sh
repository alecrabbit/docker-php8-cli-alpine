#!/usr/bin/env bash

EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', '$1/composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', '$1/composer-setup.php');")"

if [[ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm $1/composer-setup.php
    exit 1
else
    echo 'Signature OK'
    echo "Executing: $1/composer-setup.php"
fi

php $1/composer-setup.php --quiet --no-ansi --install-dir=/usr/bin --filename=composer --version=$2
RESULT=$?
rm $1/composer-setup.php
exit ${RESULT}

# if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
# then
#     >&2 echo 'ERROR: Invalid installer signature'
#     rm $1/composer-setup.php
#     exit 1
# fi
#
# php $1/composer-setup.php --quiet
# RESULT=$?
# rm $1/composer-setup.php
# exit $RESULT
