#!/bin/bash
    
USER_FIRST_NAME="$1"
USER_LAST_NAME="$2"
USER_EMAIL="$3"
USER_INSTITUTION="$4"
LICENSE="$5"


RESPONSE=$(curl -s --location --request POST 'https://msfragger-upgrader.nesvilab.org/upgrader/upgrade_download.php' \
    --form 'transfer="academic"' \
    --form 'agreement2="true"' \
    --form 'agreement3="true"' \
    --form "first_name=$USER_FIRST_NAME" \
    --form "last_name=$USER_LAST_NAME" \
    --form "email=$USER_EMAIL" \
    --form "organization=$USER_INSTITUTION" \
    --form "download=${MSFRAGGER_VERSION}.zip" \
    --form 'is_fragpipe="true"'
)

echo "$RESPONSE"

