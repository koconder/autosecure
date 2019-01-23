# Autosecure Bad-IP Blocking ##
[![Build Status](https://travis-ci.org/koconder/ostemper.svg?branch=master)](https://travis-ci.org/koconder/ostemper) [![Donate BTC](https://img.shields.io/badge/donate-BTC-orange.svg)](https://github.com/koconder/ostemper#contributing-and-donations) [![Donate ETH](https://img.shields.io/badge/donate-ETH-orange.svg)](https://etherdonation.com/d?to=0xe6fbd8de8157934767867022b7a8e8691d8df3dc)

A shell script that grabs a number of spam block-lists such as [Spamhaus DROP & EDROP Lists](https://www.spamhaus.org/drop/), [DSheild](https://en.wikipedia.org/wiki/DShield), and [Abuse.ch Free Hosts and Bad IPs](https://zeustracker.abuse.ch/blocklist.php) and adds them to `iptables` to cut down on spam and other malicious activity.

## Uses
* Secure public facing servers to common treats by blacklisting IP's known for absue
* Anti-DDOS to some level based on key threats
* Speed and Realibility using a number of sources to secure servers

## Sources Used
<pre>
Spamhaus DROP List:		https://www.spamhaus.org/drop/drop.txt
Spamhaus EDROP List:		https://www.spamhaus.org/drop/edrop.txt
Dsheild Block List:		http://feeds.dshield.org/block.txt
Abuse.ch Block List:		https://zeustracker.abuse.ch/blocklist.php?download=ipblocklist
</pre>

## Installation ##
Place the script somewhere on your server.

<pre>
# Download the script
curl -LO https://github.com/koconder/autosecure/raw/master/autosecure.sh

### make it executable
chmod +x autosecure.sh

### set it loose
sudo ./autosecure.sh

### confirm the rules have been added
sudo iptables -L Autosecure -n
</pre>

## Run-time Flags ##

To run without output "quite mode", usefull for cronjobs you can use:
<pre>./autosecure.sh -q</pre>

## Automatic Updating ##
In order for the list to automatically update each day, you'll need to setup a cron job with crontab.
<pre>
# fire up the crontab (no sudo)
crontab -e

### run the script every day at 3am
0 3 * * * /{install location}/autosecure.sh -q
</pre>


## Troubleshooting ##
If you need to remove all the Autosecure rules, run the following:
<pre>
sudo iptables -F Autosecure
sudo iptables -F AutosecureAct
</pre>

## Licences & Contributors ##

This script is licenced under GNU GPL v3, please read LICENCE.md for more information.

Based on the initial work from @cowgill and Vivek Gite (nixCraft). The initial work has been since updated with a number of additional sources. All contributions and merges from:

<pre>
David @cowgill
Vincent Koc @koconder
Volkan @volkan-k
Anasxrt @Anasxrt
ShamimIslam @ShamimIslam
</pre>
