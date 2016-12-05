FROM kartoza/pg-backup:9.4
MAINTAINER Rizky Maulana Nugraha<lana.pcfre@gmail.com>

RUN apt-get update
RUN apt-get install -y cron
RUN apt-get install -y python-dev
RUN apt-get install -y python-pip
RUN apt-get install -y python-paramiko
RUN apt-get install -y build-essential
RUN pip install --upgrade paramiko
ADD backups-cron /etc/cron.d/backups-cron
RUN touch /var/log/cron.log
ADD backups.sh /backups.sh
ADD start.sh /start.sh
ADD cleanup.sh /cleanup.sh
ADD cleanup.py /cleanup.py
ADD sftp_remote.py /sftp_remote.py
RUN chmod +x /cleanup.sh /cleanup.py
 
CMD ["/start.sh"]
