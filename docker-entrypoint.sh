#!/bin/bash

HOSTNAME=`hostname --fqdn`

echo 'ÆGIR | Hello! '
echo 'ÆGIR | When the database is ready, we will install Aegir with the following options:'
echo "ÆGIR | -------------------------"
echo "ÆGIR | Hostname: $HOSTNAME"
echo "ÆGIR | Database Host: $AEGIR_DATABASE_SERVER"
echo "ÆGIR | Makefile: $AEGIR_MAKEFILE"
echo "ÆGIR | Profile: $AEGIR_PROFILE"
echo "ÆGIR | Root: $AEGIR_HOSTMASTER_ROOT"
echo "ÆGIR | Client Name: $AEGIR_CLIENT_NAME"
echo "ÆGIR | Client Email: $AEGIR_CLIENT_EMAIL"
echo "ÆGIR | -------------------------"
echo "ÆGIR | TIP: To receive an email when the container is ready, add the AEGIR_CLIENT_EMAIL environment variable to your docker-compose.yml file."
echo "ÆGIR | -------------------------"
echo 'ÆGIR | Checking /var/aegir...'
ls -lah /var/aegir
echo "ÆGIR | -------------------------"
echo 'ÆGIR | Checking /var/aegir/.drush/...'
ls -lah /var/aegir/.drush
echo "ÆGIR | -------------------------"


# Returns true once mysql can connect.
# Thanks to http://askubuntu.com/questions/697798/shell-script-how-to-run-script-after-mysql-is-ready
mysql_ready() {
    mysqladmin ping --host=$AEGIR_DATABASE_SERVER --user=root --password=$MYSQL_ROOT_PASSWORD > /dev/null 2>&1
}

while !(mysql_ready)
do
   sleep 3
   echo "ÆGIR | Waiting for database host '$AEGIR_DATABASE_SERVER' ..."
done

echo "========================="
echo "Hostname: $HOSTNAME"
echo "Database Host: $AEGIR_DATABASE_SERVER"
echo "Makefile: $AEGIR_MAKEFILE"
echo "Profile: $AEGIR_PROFILE"
echo "Version: $AEGIR_VERSION"
echo "Client Name: $AEGIR_CLIENT_NAME"
echo "Client Email: $AEGIR_CLIENT_EMAIL"

echo "-------------------------"
echo "Running: drush cc drush"
drush cc drush

echo "Running: drush hostmaster-install"
drush hostmaster-install -y --strict=0 $HOSTNAME \
  --aegir_db_host=$AEGIR_DATABASE_SERVER \
  --aegir_db_pass=$MYSQL_ROOT_PASSWORD \
  --aegir_db_port=3306 \
  --aegir_db_user=root \
  --aegir_host=$HOSTNAME \
  --client_name=$AEGIR_CLIENT_NAME \
  --client_email=$AEGIR_CLIENT_EMAIL \
  --makefile=$AEGIR_MAKEFILE \
  --profile=$AEGIR_PROFILE \
  --root=$AEGIR_HOSTMASTER_ROOT

# Exit on the first failed line.
set -e

echo "ÆGIR | -------------------------"
echo "ÆGIR | Enabling Hosting Task Queue..."
drush @hostmaster en hosting_queued -y

echo "ÆGIR | -------------------------"
echo "ÆGIR | Hostmaster Log In Link:  "
drush @hostmaster uli

echo "ÆGIR | Running: drush cc drush "
drush cc drush

# Run whatever is the Docker CMD.
echo "ÆGIR | -------------------------"
echo "ÆGIR | Running $@ ..."
`$@`