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
  send_to_s3
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
  aws s3 cp --recursive /tmp s3://derivativearbitrage/tmp/$(date +%Y-%m-%d-%H-%M-%S)
  #  rm -rf /tmp/*
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

download_binance () {
  curdir=$(pwd)
  cd "/home/david/mktdata/binance/downloads"
  # spot or futures
  if (($#>0))
  then
    type=@1
  else
    type="futures"
  fi
  type="spot"
  url="https://data.binance.vision/data/"${type}"/um/"
  coin_list=("BTCUSDT" "ETHUSDT" "BNBUSDT" "AAVEUSDT" "XRPUSDT" "DOGEUSDT" "MATICUSDT" "DOTUSDT" "ADAUSDT" "CRVUSDT" "AVAXUSDT")
  month_list=("2022-11" "2022-10" "2022-09" "2022-08" "2022-07") # "2022-06" "2022-05" "2022-04" "2022-03" "2022-02" "2022-01" "2021-12" "2021-11")
  frequency="1m"
  for coin in ${coin_list[@]}; do
    for month in ${month_list[@]}; do
      dates=${coin}"-${frequency}-"${month}
      url=${url}"monthly/klines/"${coin}"/"${frequency}"/"${dates}".zip"
      wget $url
      unzip ${dates}".zip" && rm ${dates}".zip"
      mv ${dates}".csv" ${dates}"-"${type}"-klines.csv"

      if ($type="futures")
      then
        url=${url}"monthly/premiumIndexKlines/"${coin}"/"${frequency}"/"${dates}".zip"
        wget $url
        unzip ${dates}".zip" && rm ${dates}".zip"
        mv ${dates}".csv" ${dates}"-"${type}"-premium.csv"

        #url=${url}"daily/metrics/"${coin}"/"${dates}".zip"
        #wget $url
        #unzip ${dates}".zip" && rm ${dates}".zip"
        #mv ${dates}".csv" ${dates}"-premium.csv"
      fi

    done
  done
  cd $pwd
}

node_red () {
  cd /home/david/StakeCap/bot-systems-flows-main
  docker-compose up -d kafka neptune redis neptune-ui
  docker-compose up -d kafka-ui
  docker-compose up -d node-red-block-watchers
  docker-compose up -d node-red-amm-indexers

  google-chrome -d http://localhost:8080/ http://localhost:1880/ http://localhost:1881/
}