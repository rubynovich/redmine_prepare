#!/bin/bash -e
# FIXME script is broken

REMOTE_SERVER=192.168.100.254
REMOTE_USER=rubynovich
REMOTE_LOGIN=$REMOTE_USER@$REMOTE_SERVER

REMOTE_DB_NAME=redmine_uks
REMOTE_DB_USER=redmine_uks
REMOTE_DB_PASSWORD=rem_uks_hf45379843

LOCAL_DB_NAME=redmine
LOCAL_DB_USER=redmine
LOCAL_DB_PASSWORD=R3dm1n3

REMOTE_DB_DUMP_COMMAND=mysqldump -u$REMOTE_DB_USER -p$REMOTE_DB_PASSWORD $REMOTE_DB_NAME
LOCAL_DB_IMPORT_COMMAND=mysql -u$LOCAL_DB_USER -p$LOCAL_DB_PASSWORD $LOCAL_DB_NAME

echo "Database migration"
ssh $REMOTE_LOGIN $REMOTE_DB_DUMP_COMMAND | $LOCAL_DB_IMPORT_COMMAND
echo "ok"

REMOTE_FILES_PATH/opt/redmine/files
LOCAL_FILES_PATH=/opt/redmine-2.3/files

echo "File transfer"
sudo rsync -a $REMOTE_LOGIN:$REMOTE_FILE_PATH/* $LOCAL_FILE_PATH
echo "ok"

./redmine-shell.sh "rake db:migrate"
./redmine-shell.sh "rake redmine:plugins:migrate"

service nginx restart
