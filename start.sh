#!/bin/sh

create_env() {
    echo "[ENV FILE] creating .env file..."
    # check if file exists
    if [ -f "/var/interlegis/saap/data/secret.key" ]; then
        KEY=`cat /var/interlegis/saap/data/secret.key`
    else
        KEY=`python3 genkey.py`
        echo $KEY > data/secret.key
    fi

    FILENAME="/var/interlegis/saap/saap/.env"

    if [ -z "${DATABASE_URL:-}" ]; then
        DATABASE_URL="postgresql://saap:saap@saapdb:5432/saap"
    fi

    # ALWAYS replace the content of .env variable
    # If want to conditionally create only if absent then use IF below
    #    if [ ! -f $FILENAME ]; then

    touch $FILENAME

    # explicitly use '>' to erase any previous content
    echo "SECRET_KEY="$KEY > $FILENAME
    # now only appends
    echo "DATABASE_URL = "$DATABASE_URL >> $FILENAME
    echo "DEBUG = ""${DEBUG-True}" >> $FILENAME
    echo "EMAIL_USE_TLS = ""${USE_TLS-True}" >> $FILENAME
    echo "EMAIL_PORT = ""${EMAIL_PORT-587}" >> $FILENAME
    echo "EMAIL_HOST = ""${EMAIL_HOST-''}" >> $FILENAME
    echo "EMAIL_HOST_USER = ""${EMAIL_HOST_USER-''}" >> $FILENAME
    echo "EMAIL_HOST_PASSWORD = ""${EMAIL_HOST_PASSWORD-''}" >> $FILENAME
    echo "SOCIAL_AUTH_FACEBOOK_KEY = ""${SOCIAL_AUTH_FACEBOOK_KEY-''}" >> $FILENAME
    echo "SOCIAL_AUTH_FACEBOOK_SECRET = ""${SOCIAL_AUTH_FACEBOOK_SECRET-''}" >> $FILENAME
    echo "SOCIAL_AUTH_GOOGLE_OAUTH2_KEY = ""${SOCIAL_AUTH_GOOGLE_OAUTH2_KEY-''}" >> $FILENAME
    echo "SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET = ""${SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET-''}" >> $FILENAME
    echo "SOCIAL_AUTH_TWITTER_KEY = ""${SOCIAL_AUTH_TWITTER_KEY-''}" >> $FILENAME
    echo "SOCIAL_AUTH_TWITTER_SECRET = ""${SOCIAL_AUTH_TWITTER_SECRET-''}" >> $FILENAME
    echo "INITIAL_VALUE_FORMS_UF = ""${INITIAL_VALUE_FORMS_UF-''}" >> $FILENAME
    echo "INITIAL_VALUE_FORMS_MUNICIPIO = ""${INITIAL_VALUE_FORMS_MUNICIPIO-''}" >> $FILENAME
    echo "INITIAL_VALUE_FORMS_CEP = ""${INITIAL_VALUE_FORMS_CEP-''}" >> $FILENAME
    echo "[ENV FILE] done."
}

create_env

#python3 manage.py bower install

/bin/sh busy-wait.sh $DATABASE_URL

python3 manage.py migrate
python3 manage.py rebuild_index --noinput &

#user_created=$(python3 create_admin.py 2>&1)

#cmd=$(echo $user_created | grep 'ADMIN_USER_EXISTS')
#user_exists=$?

#cmd=$(echo $user_created | grep 'MISSING_ADMIN_PASSWORD')
#lack_pwd=$?

#if [ $user_exists -eq 0 ]; then
 #  echo "[SUPERUSER CREATION] User admin already exists. Not creating"
#fi

#if [ $lack_pwd -eq 0 ]; then
#  echo "[SUPERUSER] Environment variable $ADMIN_PASSWORD for superuser admin was not set. Leaving container"
#fi

/bin/sh gunicorn_start.sh no-venv &
/usr/sbin/nginx -g "daemon off;"
