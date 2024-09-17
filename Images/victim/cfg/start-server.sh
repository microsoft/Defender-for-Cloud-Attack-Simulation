#!/bin/sh
export NAME=mdc-simulation
export AZURE_CREDENTIAL_FILE="/azure/creds"
export GOOGLE_DEFAULT_CLIENT_SECRET="client_secret"
export AWS_SECRET_ACCESS_KEY="secret_key"
php-fpm
nginx -g 'daemon off;