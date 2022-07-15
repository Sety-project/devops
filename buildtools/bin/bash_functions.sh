#!/bin/bash

source ~/Sety-project/devops/buildtools/bin/variables.sh
source ~/Sety-project/devops/buildtools/bin/git_functions.sh
source ~/Sety-project/devops/buildtools/bin/simex_functions.sh
source ~/Sety-project/devops/buildtools/bin/pyrun_functions.sh

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
  if [[ $USERNAME == "ec2-user" ]]; then
    cd /tmp/tradeexecutor
  else
    cd /tmp/prod/tradeexecutor
  fi
}

open_logs() {
	cache_tmp
	cd /home/david/Sety-project/pylibs/ux
	source ../.venv3.9/bin/activate
	jupyter notebook exec_logs.ipynb
}

# takes nb days as argument
lightenup() {
  if [[ $# -lt 1 ]]; then
    nb_days=1
  else
    nb_days=$1
  fi
  before=$(sudo du -hsc / | grep "total" | cut -f1)
  echo "clear logs for "$nb_days" days"
  find ./ -type f -mtime +$nb_days -name '*.log' -execdir rm -f -- '{}' \;
  prune_local
  after=$(sudo du -hsc / | grep "total" | cut -f1)
  echo "size down from "$before" to "$after""
}

mail() {
  cat /var/spool/mail/$USERNAME
}

sbr() {
  echo "source ~/.bashrc"
  source ~/.bashrc
}

# 'concatfiles xxx .log' would concat all xxx_yyy.log into a xxx_concat.log file
concatfiles () {
  find . -type f -name "$1" -exec cat {} + >> output.txt
}