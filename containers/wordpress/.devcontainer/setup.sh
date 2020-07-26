#!  /bin/bash

sudo chown www-data: -R /var/www/html

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>setup.log 2>&1

# Prepare a nice name from project name for the site title.
function getTitleFromSlug()
{
    local _slug=${SLUG//-/ }
    local __slug=${_slug//_/ }
    local ___slug=( $__slug )
    echo "${___slug[@]^}"
}

echo "Setting up WordPress"

cd /var/www/html

rm -f wp-config.php

wp core download --force
wp config create --dbhost="db" --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --skip-check
wp db reset --yes
wp core install --url="$SITE_HOST:8080" --title="$(getTitleFromSlug) Development" --admin_user="$ADMIN_USER" --admin_email="$ADMIN_EMAIL" --admin_password="$ADMIN_PASS" --skip-email

echo "Install project dependencies"

source ~/.nvm/nvm.sh

# Install required node version
if [[ ! -z "$NODE_VERSION" ]] && [[ "$NODE_VERSION" != "latest" ]]
then
    nvm install $NODE_VERSION
    nvm use $NODE_VERSION
    nvm alias default $NODE_VERSION
fi

cd /var/www/html/wp-content/${PROJECT_TYPE}s/$SLUG

echo "Changed directory to $(pwd)"

if [[ "$USE_NODE" == "true" ]]
then
    npm install
fi

if [[ "$USE_COMPOSER" == "true" ]]
then
    composer install
fi

echo "Activating theme/plugin"

wp $PROJECT_TYPE activate $SLUG
