# BPQ_Ping
BPQ Ping reply server

Run the server every 10mins in crontab:

```# PING Server
*/10 * * * * sudo -u taj /home/pi/linbpq/scripts/ping.sh >> /tmp/ping.log
```

Create a mail EXPORT in BPQ to push any mail to PING at the local BBS

