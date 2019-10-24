#!/bin/bash

DIFF=$(diff /etc/crontab /etc/crontab.bak)
if [ "$DIFF" != "" ] 
then
    mail -s "Crontab" root@localhost <<  "The file  was modified"
fi
#cp /etc/crontab /etc/crontab.bak
