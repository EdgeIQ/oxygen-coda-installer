#!/bin/sh

echo "====================================================="
echo "== Uninstalling EdgeIQ Coda from the Oxygen Device =="
echo "====================================================="

# Stop the coda service
/etc/init.d/coda stop

# Remove the installation folder
rm -rf /var/coda
echo "EdgeIQ Coda has been uninstalled from the Oxygen Device"

rm -f /etc/init.d/coda
echo "Coda init.d script has been removed"

rm -f /var/log/coda*
echo "Coda logs have been removed"

# Remove the startup cron job
crontab -l | grep -v "@reboot /etc/init.d/coda restart" | crontab -
echo "Coda startup cron job has been removed"

echo "=========================================="
echo "== EdgeIQ Coda Uninstalled Successfully =="
echo "=========================================="