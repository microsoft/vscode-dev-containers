#!  /bin/bash

if test -f "style.css"; then
    PROJECT_TYPE=theme
else
    PROJECT_TYPE=plugin
fi

if test -f "composer.json"; then
    USE_COMPOSER=true
else
    USE_COMPOSER=false
fi

if test -f "package.json"; then
    USE_NODE=true
else
    USE_NODE=false
fi

/bin/cat <<EOM > .env
SLUG=$1
PROJECT_TYPE=$PROJECT_TYPE
SITE_HOST=http://localhost
ENABLE_XDEBUG=false
ADMIN_USER=admin
ADMIN_PASS=password
ADMIN_EMAIL=admin@example.com
MYSQL_DATABASE=wordpress
MYSQL_USER=admin
MYSQL_PASSWORD=password
MYSQL_ROOT_PASSWORD=password
NODE_VERSION=12
USE_COMPOSER=$USE_COMPOSER
USE_NODE=$USE_NODE
EOM
