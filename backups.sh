#!/bin/bash

source /env.sh

#echo "Running with these environment options" >> /var/log/cron.log

MYDATE=`date +%d-%B-%Y`
MONTH=$(date +%B)
YEAR=$(date +%Y)
MYBASEDIR=/backups
MYBACKUPDIR=${MYBASEDIR}/${YEAR}/${MONTH}
mkdir -p ${MYBACKUPDIR}
cd ${MYBACKUPDIR}

echo "Backup running to $MYBACKUPDIR" >> /var/log/cron.log

# ------------------------------------------------------------------------
# BACKUP Postgree First
# Loop through each pg database backing it up
# ------------------------------------------------------------------------
DBLIST=`psql -l | awk '{print $1}' | grep -v "+" | grep -v "Name" | grep -v "List" | grep -v "(" | grep -v "template" | grep -v "postgres" | grep -v "|" | grep -v ":"`
# echo "Databases to backup: ${DBLIST}" >> /var/log/cron.log
for DB in ${DBLIST}
do
  echo "Backing up $DB"  >> /var/log/cron.log
  FILENAME=${MYBACKUPDIR}/${DUMPPREFIX}_${DB}.${MYDATE}.dmp
  pg_dump -i -Fc -f ${FILENAME} -x -O ${DB}
done

FILENAME=${MYBACKUPDIR}/[GLOBAL]${DUMPPREFIX}.${MYDATE}.sql
pg_dumpall -i -f ${FILENAME} -x -O --globals-only


# ------------------------------------------------------------------------
# Preparing for sftp backups
# ------------------------------------------------------------------------
FILENAME=${MYBACKUPDIR}/${DUMPPREFIX}.${MYDATE}.tar.gz
echo "Creating compressed file $FILENAME"  >> /var/log/cron.log

cd ${MYBACKUPDIR}
FILES=`ls -I "*.tar.gz" | grep ${MYDATE}`
tar -zcvf ${FILENAME} ${FILES}

# ------------------------------------------------------------------------
# push to remote sever
# ------------------------------------------------------------------------
echo "push backup to remote server" >> /var/log/cron.log
/usr/bin/python /sftp_remote.py ${FILENAME} >> /var/log/cron.log
