#!/bin/sh
set -e

die()
{
	echo "$1"
	exit 1
}

msg()
{
	echo "$@"
}

msg "Updating php-fpm Dockerfile"
mkdir -p fpm
env -i \
    PATH=${PATH} \
    PHP_VARIANT="fpm" \
    PHP_EXECUTABLE="php-fpm" \
    CONTAINER_GROUP="www-data" \
    CONTAINER_USER="www-data" \
    envsubst '
        ${PHP_VARIANT}
        ${PHP_EXECUTABLE}
        ${CONTAINER_GROUP}
        ${CONTAINER_USER}
        ${DEFAULT_COMMAND}
        ' \
        < "Dockerfile.template" > "fpm/Dockerfile"

env -i \
    PATH=${PATH} \
    PHP_EXECUTABLE="php-fpm" \
    envsubst '
        ${PHP_EXECUTABLE}
        ' \
        < "entrypoint.template" > "fpm/php-fpm-entrypoint.sh"


cp install_composer.sh fpm/install_composer.sh

cp wait-for fpm/wait-for

msg "Updating php-cli Dockerfile"
mkdir -p cli
env -i \
    PATH=${PATH} \
    PHP_VARIANT="zts" \
    PHP_EXECUTABLE="php" \
    CONTAINER_GROUP="php-cli" \
    CONTAINER_USER="php-cli" \
    DEFAULT_COMMAND="CMD [\"-i\"]" \
    envsubst '
        ${PHP_VARIANT}
        ${PHP_EXECUTABLE}
        ${CONTAINER_GROUP}
        ${CONTAINER_USER}
        ${DEFAULT_COMMAND}
        ' \
        < "Dockerfile.template" > "cli/Dockerfile"

env -i \
    PATH=${PATH} \
    PHP_EXECUTABLE="php" \
    envsubst '
        ${PHP_EXECUTABLE}
        ' \
        < "entrypoint.template" > "cli/php-entrypoint.sh"


cp install_composer.sh cli/install_composer.sh

cp wait-for cli/wait-for

docker build -t jcsilkey/php:7.2-fpm \
    -f fpm/Dockerfile fpm

docker build -t jcsilkey/php:7.2-cli \
    -f cli/Dockerfile cli
