# oxygen-coda-installer

This repository contains one-liner scripts to install EdgeIQ Coda on the Cypress Oxygen 3 and Oxygen 3 Plus devices. 

[Oxygen 3 User Manual](./docs/Oxygen-3-Manual-v1.9.pdf)

There are couple things to keep in mind:

* Cypress Oxygen 3 and Oxygen 3 Plus devices are based on the `arm7` architecture.
* Cypress Oxygen 3 and Oxygen 3 Plus devices are not able access secured (https, mqtts) endpoints due to outdated ca-certificates.
* Cypress Oxygen 3 and Oxygen 3 Plus devices main storage is mounted at `/var`.

The installer scripts are design to address the above points.

### Prerequisites

* Oxygen device
* SSH access to the Oxygen device
* login as `admin` user

### Installing the Coda service

Connect to Oxygen device via SSH and run one-liner CLI command:

```bash
curl --retry 10 -o ./install.sh http://oxygen-coda-installer-files.s3-website-us-east-1.amazonaws.com/install.sh && chmod +x ./install.sh && sh ./install.sh
```

### Uninstalling the Coda and cleanup

Execute the following command on the device via SSH:

```bash
curl --retry 10 -o ./uninstall.sh http://oxygen-coda-installer-files.s3-website-us-east-1.amazonaws.com/uninstall.sh && chmod +x ./uninstall.sh && sh ./uninstall.sh

```

### What can be improved?

* Automatically detect the architecture of the device
* Ask for company ID as part of installation process
* Ask for unique device identifier as part of installation process
* Setup a cron job to restart the Coda service on a regular interval
* Setup a cron job to cleanup the log files on a regular interval
* Investigate automatic restart of Coda crash for some reason

### Publishing Coda Installer Files for Oxygen Devices

```bash
AWS_PROFILE=edgeiq-prod aws s3 sync . s3://oxygen-coda-installer-files --exclude ".*"
```