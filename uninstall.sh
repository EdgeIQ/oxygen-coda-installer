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

# Remove the startup cron job from /etc/init.d/start if it exists
sed -i '/coda start/d' /etc/init.d/start 2>/dev/null
echo "Coda startup command has been removed from /etc/init.d/start"

echo "=========================================="
echo "== EdgeIQ Coda Uninstalled Successfully =="
echo "=========================================="