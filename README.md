## Spamhaus DROP & EDROP List ##
A shell script that grabs the latest [Spamhaus DROP & EDROP Lists](https://www.spamhaus.org/drop/) and adds them to `iptables` to cut down on spam and other malicious activity.

## Installation ##
Place the script somewhere on your server.

<pre>
# Download the script
curl -LO https://github.com/koconder/autosecure_spamhaus/raw/master/spamhaus.sh

# make it executable
chmod +x spamhaus.sh

# set it loose
sudo ./spamhaus.sh

# confirm the rules have been added
sudo iptables -L Spamhaus -n
</pre>

## Automatic Updating ##
In order for the list to automatically update each day, you'll need to setup a cron job with crontab.
<pre>
# fire up the crontab (no sudo)
crontab -e

# run the script every day at 3am
0 3 * * * /home/YOUR-USERNAME/bin/spamhaus.sh
</pre>


## Troubleshooting ##
If you need to remove all the Spamhaus rules, run the following:
<pre>
sudo iptables -F Spamhaus
</pre>
<pre>
sudo iptables -F SpamhausAct
</pre>
