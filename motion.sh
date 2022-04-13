#!/usr/bin/env bash

export BASEDIR="$(cd $(dirname ${BASH_SOURCE[0]}) >/dev/null 2>&1 && pwd)"
source ${BASEDIR}/.definitions.sh

config_file="${BASEDIR}/config/motion.conf"
send_file_path="/home/pi/.motion"
backup_path="${send_file_path}/backup"

[[ -d ${backup_path} ]] || mkdir ${backup_path}

#this format has better support in telegram app
file_extension="mp4"
#min size of file to send it. (~36k)
minimumsize=35000
# max size
maxsize=20000000
# porcentagem do uso de disco
sdcardspace_limit=80

exitOnError() {
  # usage: exitOnError <output_message> [optional: code (defaul:exit code)]
  code=${2:-$?}
  if [[ $code -ne 0 ]]; then
      if [ ! -z "$1" ]; then echo -e "ERROR: $1" >&2 ; fi
      echo "Exiting..." >&2
      exit $code
  fi
}

# Send the file command
curl_cmd() {
	local file message
	file=$1
	if [[ -f ${file} ]]; then
		message="Enviando arquivo: ${file##*/}"
		curl --silent -X POST \
                 -d chat_id=${NOTIFICATION_ID} \
                 -d text="${message}" \
                 ${api_url}/bot${TELEGRAM_TOKEN}/sendMessage &> /dev/null

		curl --silent -F \
				video=@"${file}" \
				${api_url}/bot${TELEGRAM_TOKEN}/sendVideo?chat_id=${NOTIFICATION_ID} &> /dev/null
	else
		message="$1"
		curl --silent -X POST \
                 -d chat_id=${NOTIFICATION_ID} \
                 -d text="${message}" \
                 ${api_url}/bot${TELEGRAM_TOKEN}/sendMessage &> /dev/null
	fi
}

# Looking for dependencies
lsusb | grep -i webcam || exitOnError "==============\nVerifique se a webcam está bem conectada!!!\n=============="
which curl || exitOnError "==============\nFirst run:\nsudo apt-get install -y curl\n=============="
which motion || exitOnError "==============\nFirst run:\nsudo apt-get install -y motion\n=============="

# Adding the custom config file
if [[ ! -d ${send_file_path} ]]; then
	mkdir -p ${send_file_path}
	echo -e "==============\nDiretório do motion criado!!!\n=============="
	cp ${config_file} ${send_file_path}
	echo -e "==============\nArquivo de configuração copiado!\n=============="
else
	cp ${config_file} ${send_file_path}
	echo -e "==============\nArquivo de configuração copiado!\n=============="
fi

# Run Motion in daemon mode with custom config file if not already started
motionpid=$(ps -ef | grep "motion.conf" | grep -v grep | awk '{print $2}')
if [[ -z ${motionpid} ]]; then
	/usr/bin/motion -b -c ${send_file_path}/motion.conf
	echo -e "==============\nMotion inicializado!\n=============="
fi

has_file=($(find ${send_file_path} -name "*.${file_extension}"))
if [[ -n ${has_file} ]]; then
	echo -e "==============\nArquivos encontrados!\n=============="
	for f in ${has_file[@]}; do
		actualsize=$(wc -c <"${f}")
		if [[ ${actualsize} -ge ${minimumsize} ]] && [[ ${actualsize} -lt ${maxsize} ]]; then
			curl_cmd ${f}
			echo -e "==============\nNotificação enviada para o usuário!\n=============="
			mv ${f} ${f}.disabled
		elif [[ ${actualsize} -ge ${maxsize} ]]; then
			echo -e "==============\nArquivo excede limite (salvando em backup)\n=============="
			mv ${f} ${backup_path}/${f##*/}.disabled
			curl_cmd "${f##*/} Não enviado. Movido para backup (maior que 20MB)"
		else
			echo -e "==============\nArquivo muito pequeno (desconsiderando)\n=============="
			mv ${f} ${backup_path}/${f##*/}.disabled
			curl_cmd "${f##*/} Não enviado. Movido para backup (muito pequeno)"
		fi
	done
else
	echo -e "==============\nNenhum arquivo encontrado no momento\n=============="
	#curl_cmd "Nenhuma movimentação detectada por enquanto..."
fi

currspace=$(df -h / | awk '{ print $5 }' | tail -n 1 | cut -d'%' -f1)
if [[ ${currspace} -gt ${sdcardspace_limit} ]]; then
	curl_cmd "!!! Usando ${currspace}% da capacidade de disco) Executando limpeza dos arquivos já enviados"
	echo -e "==============\n!!! Usando ${currspace}% da capacidade de disco) Executando limpeza dos arquivos já enviados\n=============="
	rm -vfr ${send_file_path}/*.disabled
fi