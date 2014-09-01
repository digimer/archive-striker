#!/bin/bash
#
# Run monthly to keep 6 months worth of records.
# crontab: 0 0 1 * *  /root/archive_striker-monitor.log.sh > /dev/null

# Delete the oldest archive
if [ -e "/var/log/striker-monitor.log.6.bz2" ]
then
	rm -f /var/log/striker-monitor.log.6.bz2
fi

# Move 5 to 6
if [ -e "/var/log/striker-monitor.log.5.bz2" ]
then
	mv /var/log/striker-monitor.log.5.bz2 /var/log/striker-monitor.log.6.bz2
fi

# Move 4 to 5
if [ -e "/var/log/striker-monitor.log.4.bz2" ]
then
	mv /var/log/striker-monitor.log.4.bz2 /var/log/striker-monitor.log.5.bz2
fi

# Move 3 to 4
if [ -e "/var/log/striker-monitor.log.3.bz2" ]
then
	mv /var/log/striker-monitor.log.3.bz2 /var/log/striker-monitor.log.4.bz2
fi

# Move 2 to 3
if [ -e "/var/log/striker-monitor.log.2.bz2" ]
then
	mv /var/log/striker-monitor.log.2.bz2 /var/log/striker-monitor.log.3.bz2
fi

# Move 1 to 2
if [ -e "/var/log/striker-monitor.log.1.bz2" ]
then
	mv /var/log/striker-monitor.log.1.bz2 /var/log/striker-monitor.log.2.bz2
fi

# Move current to 1 and compress it
if [ -e "/var/log/striker-monitor.log" ]
then
	cp /var/log/striker-monitor.log /var/log/striker-monitor.log.1
	cat /den/null > /var/log/striker-monitor.log
	bzip2 /var/log/striker-monitor.log.1
fi
