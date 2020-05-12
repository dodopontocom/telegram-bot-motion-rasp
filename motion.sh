#!/bin/bash
#

export BASEDIR="$(cd $(dirname ${BASH_SOURCE[0]}) >/dev/null 2>&1 && pwd)"
source ${BASEDIR}/.definitions.sh

config_file="${BASEDIR}/config/motion.conf"
send_file_path="/home/${USER}/.motion/"
api_url="https://api.telegram.org"

# Send the file command
curl_cmd() {
	local file
	file=$1
	curl --silent -F document=@"${file}" ${api_url}/bot${TELEGRAM_TOKEN}/sendDocument?chat_id=${NOTIFICATION_ID}
}

# Looking for dependencies
which curl || echo -e "First run:\nsudo apt-get install -y curl"
which motion || echo -e "First run:\nsudo apt-get install -y motion"

# Adding the custom config file
mkdir -p ${send_file_path}
cp ${config_file} ${send_file_path}

# Run Motion in daemon mode with custom config file
/usr/bin/motion -b -c ${send_file_path}/motion.conf

file_extension="mkv"

has_file=($(find ${send_file_path} -name "*.${file_extension}"))
if [[ -n ${has_file} ]]; then
	for f in ${has_file[@]}; do
		curl_cmd ${f}
	done
fi