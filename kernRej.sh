#/bin/bash

journalctl -k | grep REJECT |grep -v 'DST=.*255' |awk '{print $1, $2, $3, $6, $10, $11, $17, $18, $19, $20}'