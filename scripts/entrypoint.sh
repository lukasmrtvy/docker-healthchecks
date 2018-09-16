#!/bin/bash

export SD_USER=${SD_USER:-admin}
export SD_PASS=${SD_PASS:-admin}


local_settings_path="/opt/healthchecks/hc/local_settings.py"

export DB_TYPE=${DB_TYPE:-sqlite}

touch "${local_settings_path}"

cat <<EOF > /opt/healthchecks/hc/local_settings.py
import os

BASE_DIR = '/opt/healthchecks'

EOF

case "${DB_TYPE}" in
        "sqlite")
        cat <<-EOF >> "${local_settings_path}"
                DATABASES = {
                     'default': {
                        'ENGINE': 'django.db.backends.sqlite3',
                        'NAME': '{0}/hc.sqlite'.format(BASE_DIR),
                             }
                }
        EOF
        ;;
        "mysql" | "postgres")
        cat <<-EOF >>  "${local_settings_path}"
                DATABASES = {
                    'default': {
                        'ENGINE':   'django.db.backends' + os.environ['DB_TYPE'],
                        'HOST':     os.environ['DB_HOST'],
                        'PORT':     os.environ['DB_PORT'],
                        'NAME':     os.environ['DB_NAME'],
                        'USER':     os.environ['DB_USER'],
                        'PASSWORD': os.environ['DB_PASSWORD'],
                        'TEST': {'CHARSET': 'UTF8'}
                     }
                }
        EOF
        ;;
        *)
           echo "wrong db selected"
           exit 1
        ;;
esac


cat <<EOF >> /opt/healthchecks/hc/local_settings.py

if "HOST" in os.environ:
        HOST = repr(os.environ['HOST'])

if "SECRET_KEY" in os.environ:
        SECRET_KEY = repr(os.environ['SECRET_KEY'])

if "DEBUG" in os.environ:
        DEBUG = os.environ['DEBUG']

if "ALLOWED_HOSTS" in os.environ:
        ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS')

if "DEFAULT_FROM_EMAIL" in os.environ:
        DEFAULT_FROM_EMAIL = repr(os.environ['DEFAULT_FROM_EMAIL'])

if "USE_PAYMENTS" in os.environ:
        USE_PAYMENTS = os.environ['USE_PAYMENTS']

if "REGISTRATION_OPEN" in os.environ:
        REGISTRATION_OPEN = os.environ.get("REGISTRATION_OPEN") == "True"

if "SITE_ROOT" in os.environ:
        SITE_ROOT = repr(os.environ['SITE_ROOT'])

if "SITE_NAME" in os.environ:
        SITE_NAME = repr(os.environ['SITE_NAME'])

if "PING_EMAIL_DOMAIN" in os.environ: 
        PING_EMAIL_DOMAIN  = repr(os.environ['PING_EMAIL_DOMAIN'])

if "DISCORD_CLIENT_ID" in os.environ:
        DISCORD_CLIENT_ID = repr(os.environ['DISCORD_CLIENT_ID'])
        DISCORD_CLIENT_SECRET = repr(os.environ['DISCORD_CLIENT_SECRET'])

if "DISCORD_CLIENT_ID" in os.environ:
        SLACK_CLIENT_ID = os.environ['SLACK_CLIENT_ID']
        SLACK_CLIENT_SECRET = os.environ['SLACK_CLIENT_SECRET']

if "DISCORD_CLIENT_ID" in os.environ:
        PUSHOVER_API_TOKEN = os.environ['PUSHOVER_API_TOKEN']
        PUSHOVER_SUBSCRIPTION_URL = os.environ['PUSHOVER_SUBSCRIPTION_URL']
        PUSHOVER_EMERGENCY_RETRY_DELAY = os.environ['PUSHOVER_EMERGENCY_RETRY_DELAY']
        PUSHOVER_EMERGENCY_EXPIRATION = os.environ['PUSHOVER_EMERGENCY_EXPIRATION']

if "DISCORD_CLIENT_ID" in os.environ:
        PUSHBULLET_CLIENT_ID = os.environ['USHBULLET_CLIENT_ID']
        PUSHBULLET_CLIENT_SECRET = os.environ['PUSHBULLET_CLIENT_SECRET']

if "DISCORD_CLIENT_ID" in os.environ:
        TELEGRAM_BOT_NAME = os.environ['TELEGRAM_BOT_NAME']
        TELEGRAM_TOKEN = os.environ['TELEGRAM_TOKEN']

if "DISCORD_CLIENT_ID" in os.environ:
        TWILIO_ACCOUNT = os.environ['TWILIO_ACCOUNT']
        TWILIO_AUTH = os.environ['TWILIO_AUTH']
        TWILIO_FROM = os.environ['TWILIO_FROM']

if "DISCORD_CLIENT_ID" in os.environ:
        PD_VENDOR_KEY = os.environ['PD_VENDOR_KEY']

if "DISCORD_CLIENT_ID" in os.environ:
        ZENDESK_CLIENT_ID = os.environ['ZENDESK_CLIENT_ID']
        ZENDESK_CLIENT_SECRET = os.environ['ZENDESK_CLIENT_SECRET']

EOF

if [ "${DB_MIGRATE}" = "true" ];
then
        /opt/healthchecks/manage.py migrate --noinput
fi

if [ -n "${USER}" ] && [ -n "${EMAIL}" ];then
        /opt/healthchecks/manage.py createsuperuser --noinput --username "${USER}" --email "${EMAIL}"
fi

exec "$@"
