#!/bin/bash

source ~/Sety-project/devops/buildtools/bin/variables.sh
source ~/Sety-project/devops/buildtools/bin/git_functions.sh
source ~/Sety-project/devops/buildtools/bin/simex_functions.sh
source ~/Sety-project/devops/buildtools/bin/python_functions.sh

j() {
	REPOS=(config mktdata .cache .ssh .aws)
	
	if [[ " ${REPOS[*]} " =~ " $1 " ]]; then
		cd ~/$1
		return
	fi

	cd ~/Sety-project/$1
}

jpl() {
    cd ~/Sety-project/pylibs/$1
}

jtt() {
  cd /tmp/tradeexecutor
}

open_logs() {
	cache_tmp
	cd /home/david/Sety-project/pylibs/ux
	source ../.venv3.9/bin/activate
	jupyter notebook exec_logs.ipynb
}

clear_log() {
  find ./ -type f -mtime +$1 -name '*.log' -execdir rm -f -- '{}' \;
}

read_mail() {
  cat /var/spool/mail/ec2-user
}

# du -hsc *

