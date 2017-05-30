import sys
import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "saap.settings")
django.setup()

from saap.core.models import User

def create_superuser():
    password = os.environ['ADMIN_PASSWORD'] if 'ADMIN_PASSWORD' in os.environ else 'interlegis'
    email = os.environ['ADMIN_EMAIL'] if 'ADMIN_EMAIL' in os.environ else 'interlegis@leg.br'

    if User.objects.filter(email=email).exists():
        print("[SUPERUSER] User %s already exists. Exiting without change." % email)
        sys.exit('ADMIN_USER_EXISTS')
    else:
        if not password:
            print("[SUPERUSER] Environment variable $ADMIN_PASSWORD for user %s was not set. Leaving..." % email)
            sys.exit('MISSING_ADMIN_PASSWORD')

        print("[SUPERUSER] Creating superuser...")

        u = User.objects.create_superuser(email=email,password=password)
        u.save()

        print("[SUPERUSER] Done.")

        sys.exit(0)

if __name__ == '__main__':
    create_superuser()