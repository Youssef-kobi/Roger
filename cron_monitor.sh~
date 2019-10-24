#!/bin/bash

DIFF=$(diff /etc/crontab /etc/crontab.bak)
if [ "$DIFF" != "" ] 
then
    echo "The file  was modified"
fi
#cp /etc/crontab /etc/crontab.bak
