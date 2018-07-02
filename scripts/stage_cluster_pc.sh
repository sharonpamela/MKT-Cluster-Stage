#!/bin/bash

# Script file name
MY_SCRIPT_NAME=`basename "$0"`

# Derive HPOC number from IP 3rd byte
MY_CVM_IP=$(/sbin/ifconfig eth0 | grep 'inet ' | awk '{ print $2}')
array=(${MY_CVM_IP//./ })
MY_HPOC_NUMBER=${array[2]}

# Source Nutanix environments (for PATH and other things)
source /etc/profile.d/nutanix_env.sh

# Logging function
function my_log {
    #echo `$MY_LOG_DATE`" $1"
    echo $(date "+%Y-%m-%d %H:%M:%S") $1
}

# Set Prism Central Password to Prism Element Password
my_log "Setting PC password to PE password"
ncli user reset-password user-name="admin" password="${MY_PE_PASSWORD}"

# Add NTP Server\
my_log "Configure NTP on PC"
ncli cluster add-to-ntp-servers servers=0.us.pool.ntp.org,1.us.pool.ntp.org,2.us.pool.ntp.org,3.us.pool.ntp.org

# Accept Prism Central EULA
my_log "Validate EULA on PC"
curl -u admin:${MY_PE_PASSWORD} -k -H 'Content-Type: application/json' -X POST \
  https://10.20.${MY_HPOC_NUMBER}.39:9440/PrismGateway/services/rest/v1/eulas/accept \
  -d '{
    "username": "SE",
    "companyName": "NTNX",
    "jobTitle": "SE"
}'

# Disable Prism Central Pulse
my_log "Disable Pulse on PC"
curl -u admin:${MY_PE_PASSWORD} -k -H 'Content-Type: application/json' -X PUT \
  https://10.20.${MY_HPOC_NUMBER}.39:9440/PrismGateway/services/rest/v1/pulse \
  -d '{
    "emailContactList":null,
    "enable":false,
    "verbosityType":null,
    "enableDefaultNutanixEmail":false,
    "defaultNutanixEmail":null,
    "nosVersion":null,
    "isPulsePromptNeeded":false,
    "remindLater":null
}'
