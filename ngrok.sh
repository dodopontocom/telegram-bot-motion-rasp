#!/usr/bin/env bash

export BASEDIR="$(cd $(dirname ${BASH_SOURCE[0]}) >/dev/null 2>&1 && pwd)"
source ${BASEDIR}/.definitions.sh

currentngrokurl=$(cat /tmp/ngrok.log | grep -Eo url=https.* | cut -d'=' -f2 | tail -1)

ngrokpid=$(ps -ef | grep -E "ngrok http 8081" | grep -v grep | awk '{print $2}')
if [[ -z ${ngrokpid} ]]; then
    ngrok authtoken ${ngrokauthtoken} >/dev/null 2>&1
    ngrok http 8081 -log stdout &
    sleep 20
fi

maybe_new_ngrokurl=$(cat /tmp/ngrok.log | grep -Eo url=https.* | cut -d'=' -f2 | tail -1)
if [[ "${currentngrokurl}" != "${maybe_new_ngrokurl}" ]]; then
    message="Nova url para o monitoramento: ${maybe_new_ngrokurl}"
    curl --silent -X POST \
            -d chat_id=${NOTIFICATION_ID} \
            -d text="${message}" \
            ${api_url}/bot${TELEGRAM_TOKEN}/sendMessage &> /dev/null
fi