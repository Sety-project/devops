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
    nb_days=7
  else
    nb_days=$1
  fi
  before=$(sudo du -hsc / | grep "total" | cut -f1)
  size=$(cut -d G -f1 <<< $before)
  echo $size
  if [[ $size -gt 20 ]]; then
    echo "clear logs for "$nb_days" days"
    find ./ -type f -mtime +$nb_days -name '*.log' -execdir rm -f -- '{}' \;
    find ./ -type f -mtime +$nb_days -name '*.json' -execdir send_to_s3 -- '{}' \;
    prune_local
    after=$(sudo du -hsc / | grep "total" | cut -f1)
    echo "size down from "$before" to "$after""
  else
    echo "size "$before" is ok. lightenup skipped"
  fi
}

clearold() {
  if [[ $# -lt 1 ]]; then
    nb_min=60
  else
    nb_min=$1
  fi
  find ./ -type f -mmin +$nb_min -execdir rm -f -- '{}' \;
}

send_to_s3() {
  echo "$1"
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