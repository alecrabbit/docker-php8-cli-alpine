#!/usr/bin/env bash

docker build -t dralec/php-alpine .

docker push dralec/php-alpine
