
# Powershell Wireguard Connection Checker 

This is a simple Powershell script to check if we are connected to correct netwrok (or are we connected at all ?), if not it restarts wireguard and checks again with specific configuration.

Problem arised while running PowerBI Gateway (It only supports Windows Machine), I had to use wireguard for VPN services (don't ask why), but it had problem time to time. It used to stuck while connecting to VPN, so server was left out of internet connecten, so I had to restart server and rerun it.  So I came up to solution to write powershell script, which periodically checks network status and reconnects to desired  network using VPN configuration file.

### Usage

- Clone / Download Shell Script.
- Configure the script for your own needs.
- Use Windows Task Scheduler for Periodical Run (AKA. Cron Job)
