#!/bin/bash
#

export BASEDIR="$(cd $(dirname ${BASH_SOURCE[0]}) >/dev/null 2>&1 && pwd)"
source ${BASEDIR}/.definitions.sh

config_file="${BASEDIR}/config/motion.conf"
send_file_path="/home/pi/.motion"
api_url="https://api.telegram.org"

# Send the file command
curl_cmd() {
	local file message
	file=$1
	if [[ -n ${file} ]]; then
		message="Enviando arquivo: ${file}"
		curl --silent -X POST \
                 -d chat_id=${NOTIFICATION_ID} \
                 -d text="${message}" \
                 ${api_url}/bot${TELEGRAM_TOKEN}/sendMessage &> /dev/null

		curl --silent -F document=@"${file}" ${api_url}/bot${TELEGRAM_TOKEN}/sendDocument?chat_id=${NOTIFICATION_ID} &> /dev/null
	else
		message="Nenhum arquivo encontrado no momento"
		# curl --silent -X POST \
        #         -d chat_id=${NOTIFICATION_ID} \
        #         -d text="${message}" \
        #         ${api_url}/bot${TELEGRAM_TOKEN}/sendMessage &> /dev/null
	fi
}

# Looking for dependencies
lsusb | grep -i webcam || echo "==============\nVerifique se a webcam está bem conectada!!!\n=============="
which curl || echo -e "==============\nFirst run:\nsudo apt-get install -y curl\n=============="
which motion || echo -e "==============\nFirst run:\nsudo apt-get install -y motion\n=============="

# Adding the custom config file
if [[ ! -f ${send_file_path} ]]; then
	mkdir -p ${send_file_path}
	echo "==============\nDiretório do motion criado!!!\n=============="
	cp ${config_file} ${send_file_path}
	echo "==============\nArquivo de configuração copiado!\n=============="
else
	cp ${config_file} ${send_file_path}
	echo "==============\nArquivo de configuração copiado!\n=============="
fi

# Run Motion in daemon mode with custom config file
if [[ ! $(ps -ef | grep "motion" | grep -v grep) ]]; then
	/usr/bin/motion -b -c ${send_file_path}/motion.conf
	echo "==============\nMotion inicializado!\n=============="
fi

file_extension="mkv"

has_file=($(find ${send_file_path} -name "*.${file_extension}"))
if [[ -n ${has_file} ]]; then
	echo "==============\nArquivos encontrados!\n=============="
	for f in ${has_file[@]}; do
		curl_cmd ${f}
		echo "==============\nNotificação enviada para o usuário!\n=============="
		mv ${f} ${f}.disabled
	done
else
	echo "==============\nNenhum arquivo encontrado no momento\n=============="
	curl_cmd
fi