# BPQ_Ping
BPQ Ping reply server

Run the server every 10mins in crontab:

```# PING Server
*/10 * * * * sudo -u taj /home/pi/linbpq/scripts/ping.sh >> /tmp/ping.log
```

Create a mail EXPORT in BPQ to push any mail to PING at the local BBS

Only trouble is, PING is not a good callsign to send to or from. So this is a bit pointless!
(BPQ Mail will block the callsign of PING)

