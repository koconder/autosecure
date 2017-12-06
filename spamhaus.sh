#!/bin/bash

# Automatic pulling of spam lists to block IP's
# Copyright (C) 2013 David @cowgill
# Copyright (C) 2014 Vincent Koc @koconder
# Copyright (C) 2014 Volkan @volkan-k
# Copyright (C) 2016 Anasxrt @Anasxrt

# based off the following two scripts
# http://www.theunsupported.com/2012/07/block-malicious-ip-addresses/
# http://www.cyberciti.biz/tips/block-spamming-scanning-with-iptables.html

# logger from @phracker
_log () {
  echo -e "$(date "+%Y-%m-%d %H:%M:%S.%N"): $@" | tee -a /var/log/spamhaus.log
}

# path to iptables
IPTABLES="$(which iptables)";
if [[ $IPTABLES == "" ]]; then
  _log "No iptables binary detected. Please edit your PATH."
  exit 1;
fi

# list of known spammers
URL1="https://www.spamhaus.org/drop/drop.txt";
URL2="https://www.spamhaus.org/drop/edrop.txt";


# save local copy here
FILE1="/tmp/spamhaus_drop.txt";
FILE2="/tmp/spamhaus_edrop.txt";

# iptables custom chain for Bad IPs
CHAIN="Spamhaus";
# iptables custom chain for actions
CHAINACT="SpamhausAct";

# Outbound (egress) filtering is not required but makes your Spamhaus setup
# complete by providing full inbound and outbound packet filtering. You can
# toggle outbound filtering on or off with the EGF variable.
# It is strongly recommended that this option NOT be disabled.
EGF="1"

# check to see if the chain already exists
$IPTABLES -L $CHAIN -n &> /dev/null

# check to see if the chain already exists
if [ $? -eq 0 ]; then

    # flush the old rules
    $IPTABLES -F $CHAIN &> /dev/null
    _log "Flushed old rules. Applying updated Spamhaus list..."

else

    # create a new chain set
    $IPTABLES -N $CHAIN &> /dev/null

    # tie chain to input rules so it runs
    $IPTABLES -A INPUT -j $CHAIN &> /dev/null

    # don't allow this traffic through
    $IPTABLES -A FORWARD -j $CHAIN &> /dev/null

    if [ $EGF -ne 0 ]; then
        # don't allow access to bad IPs from us
        $IPTABLES -A OUTPUT -j $CHAIN &> /dev/null
    fi

    _log "Chain not detected. Creating new chain and adding Spamhaus list..."

fi;

# create a new action set
$IPTABLES -N $CHAINACT &> /dev/null

# flush the old action rules
$IPTABLES -F $CHAINACT &> /dev/null

# add the ip address log rule to the action chain
$IPTABLES -A $CHAINACT -p 0 -j LOG --log-prefix "[SPAMHAUS BLOCK]" -m limit --limit 3/min --limit-burst 10  &> /dev/null

# add the ip address drop rule to the action chain
$IPTABLES -A $CHAINACT -p 0 -j DROP &> /dev/null

for bl in 1 2
do
    URL="URL${bl}"
    URL="${!URL}"
    FILE="FILE${bl}"
    FILE="${!FILE}"
    # get a copy of the spam list
    _log "Downloading ${URL} to ${FILE}..."
    wget -qc ${URL} -O ${FILE}

    # iterate through all known spamming hosts
    _log "Parsing hosts in ${FILE}..."
    for IP in $( cat $FILE | egrep -v '(^;|^#.*|^$)' | awk '{ print $1}' ); do

        # add the ip address to the chain (source filter)
        $IPTABLES -A $CHAIN -p 0 -s $IP -j $CHAINACT

        if [ $EGF -ne 0 ]; then
            # add the ip address to the chain (destination filter)
            $IPTABLES -A $CHAIN -p 0 -d $IP -j $CHAINACT
        fi
        _log "IP: ${IP}"

    done
    # remove the spam list
    _log "Done parsing ${FILE}. Removing..."
    unlink ${FILE}
done

_log "Completed."
