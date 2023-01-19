#!/bin/bash

echo MYSQL_PASSWORD=$(echo $RANDOM | sha256sum | head -c 20; echo;) >> .env
