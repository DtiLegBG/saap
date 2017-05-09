#!/bin/bash

# As seen in http://tutos.readthedocs.org/en/latest/source/ndg.html

saap_DIR="/var/interlegis/saap"

# Seta um novo diretório foi passado como raiz para o saap
# caso esse tenha sido passado como parâmetro
if [ "$1" ]
then
    saap_DIR="$1"
fi

NAME="saap"                                     # Name of the application (*)
DJANGODIR=/var/interlegis/saap/                    # Django project directory (*)
SOCKFILE=/var/interlegis/saap/run/gunicorn.sock    # we will communicate using this unix socket (*)
USER=`whoami`                                   # the user to run as (*)
GROUP=`whoami`                                  # the group to run as (*)
NUM_WORKERS=9                                   # how many worker processes should Gunicorn spawn (*)
                                                # NUM_WORKERS = 2 * CPUS + 1
DJANGO_SETTINGS_MODULE=saap.settings            # which settings file should Django use (*)
DJANGO_WSGI_MODULE=saap.wsgi                    # WSGI module name (*)

echo "Starting $NAME as `whoami` on base dir $saap_DIR"

# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user $USER \
  --bind=unix:$SOCKFILE
