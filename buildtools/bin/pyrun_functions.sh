#/bin/bash

export ECR_REGION=eu-west-2

pystop(){
  if [[ $1 != "" ]]; then
 	  docker rm -f $(docker ps -aq --filter name="$1")
 	else
 	  docker rm -f $(docker ps -aq)
 	fi
}

pyrun() {
  # because the run.sh demands them, all params must be passed incl optionals. "not_passed" will apply default from python script
  gpa

	docker_login
	REPO_LIST=$(aws ecr describe-repositories --region $ECR_REGION --query "repositories[].repositoryName" --output text)
	FOUND=0
	if [[ $# -ne 0 ]] ; then
		# Tries to identify the project name
		for repo in $REPO_LIST; do
			if [ $repo == $1 ]; then
				FOUND=1
				PYTHON_PROJECT=$1
				shift
			fi
		done
	fi
	if [[ $FOUND -eq 0 ]] ; then
		# Project not found, assigning
		PYTHON_PROJECT=`pwd | sed 's#.*/##'`
		# If project not in repo list, terminating
		echo $REPO_LIST | grep -w -q $PYTHON_PROJECT
		if [[ $? == 1 ]]; then
			return
		fi
	fi

	IS_DOCKER_RUNNING=`systemctl status docker | grep Active | grep running | wc -l`

	if [[ $IS_DOCKER_RUNNING -eq 0 ]] ; then
		sudo /bin/systemctl start docker.service
	fi

	docker rm $(docker ps --filter status=exited -q)
	docker pull $PYTHON_REGISTRY/$PYTHON_PROJECT:latest

  # they're in fact both running without detach falg...
	if [[ $USERNAME == "ubuntu" ]]; then
	  docker run -e USERNAME=$USERNAME "${@}" \
	  -v ~/Sety-project/static:/home/ubuntu/Sety-project/static \
	  -v ~/Sety-project/mktdata:/home/ubuntu/Sety-project/mktdata \
	  -v ~/.cache/setyvault:/home/ubuntu/.cache/setyvault \
	  -v ~/Sety-project/config/prod:/home/ubuntu/Sety-project/config \
	  -v /tmp:/tmp \
	  --network host $PYTHON_REGISTRY/$PYTHON_PROJECT:latest
	else
	  docker run -e USERNAME=$USERNAME "${@}" \
	  -v ~/Sety-project/static:/home/ubuntu/Sety-project/static \
	  -v ~/Sety-project/mktdata:/home/ubuntu/Sety-project/mktdata \
	  -v ~/.cache/setyvault:/home/ubuntu/Sety-project/.cache/setyvault \
	  -v ~/Sety-project/config/prod:/home/ubuntu/Sety-project/config \
	  -v /tmp:/tmp \
	  --network host $PYTHON_REGISTRY/$PYTHON_PROJECT:latest
	fi
}

#################################
# For calls on the EC2 instance #
#################################

pyrun_static(){
	pyrun staticdata -d --rm --name=static_worker
	echo "launched pyrun_static"
}

# no need to run interactive since it's blocking in pyrun_all
pyrun_histfeed(){
  #pyrun histfeed -it --rm --name=histfeed_worker_ -e EXCHANGE="ftx" -e RUN_TYPE="build" -e UNIVERSE="all" -e NB_DAYS="not_passed"
	pyrun histfeed -d --rm --name=histfeed_worker_"$1" \
	-e EXCHANGE="$1" \
	-e RUN_TYPE="build" \
	-e UNIVERSE="all" \
	-e NB_DAYS="not_passed"
  echo "launched pyrun_histfeed"
  cd /tmp/histfeed
}

pyrun_pfoptimizer(){
  echo "removing old shards"
  if [[ $USERNAME == "ubuntu" ]]; then
    DIRNAME=~/Sety-project/config/prod/pfoptimizer
  else
    DIRNAME=~/Sety-project/config/pfoptimizer
  fi
  find $DIRNAME -name "weights_"$2"_"$3"***.json" -exec rm -f {} \;

	#pyrun pfoptimizer -it --rm --name=pfoptimizer_worker_ -e RUN_TYPE="sysperp" -e EXCHANGE="ftx" -e SUBACCOUNT="debug" -e TYPE="not_passed" -e DEPTH="not_passed" -e CONFIG="not_passed" -e COIN="not_passed" -e CASH_SIZE="not_passed"
	pyrun pfoptimizer -d --rm --name=pfoptimizer_worker_"$2"_"$3" \
	-e RUN_TYPE="$1" \
  -e EXCHANGE="$2" \
  -e SUBACCOUNT="$3" \
	-e CONFIG="not_passed" \
	-e TYPE="not_passed" \
	-e DEPTH="not_passed" \
	-e COIN="not_passed" \
	-e CASH_SIZE="not_passed"
	echo "launched pyrun_pfoptimizer $1 $2 $3"
	cd /tmp/pfoptimizer/
}

pyrun_riskpnl(){
  #pyrun riskpnl -it --rm --name=riskpnl_worker_ -e RUN_TYPE="plex" -e EXCHANGE="ftx" -e SUBACCOUNT="debug" -e NB_RUNS="not_passed" -e PERIOD="not_passed" -e DIRNAME="not_passed" -e FILENAME="not_passed" -e CONFIG="not_passed"
  pyrun riskpnl -d --rm --name=riskpnl_worker_"$1"_"$2" \
	-e RUN_TYPE="plex" \
  -e EXCHANGE="$1" \
  -e SUBACCOUNT="$2" \
	-e NB_RUNS="not_passed" \
	-e PERIOD="not_passed" \
	-e DIRNAME="not_passed" \
	-e FILENAME="not_passed" \
	-e CONFIG="not_passed"
	echo "launched pyrun_riskpnl $1 $2"
	cd /tmp/riskpnl/
}

pyrun_tradeexecutor(){
	if [[ $USERNAME == "ubuntu" ]]; then
    DIRNAME="/home/$USERNAME/Sety-project/config/prod/pfoptimizer"
  else
    DIRNAME="/home/$USERNAME/Sety-project/config/pfoptimizer"
  fi
	for order in $( ls $DIRNAME | grep weights_"$1"_"$2"_ ); do
    #pyrun tradeexecutor -it --restart=on-failure --name="tradeexecutor_" -e ORDER="weights_ftx_debug_ETH.json" -e CONFIG="not_passed" -e EXCHANGE="ftx" -e SUBACCOUNT="debug"
    pyrun tradeexecutor -it --name="tradeexecutor_"$order"" -e ORDER="$order" -e CONFIG="not_passed" -e EXCHANGE="$1" -e SUBACCOUNT="$2"
    echo "launched pyrun_tradeexecutor "$order""
  done
  cd /tmp/tradeexecutor/
}

pyrun_listen(){
  pyrun tradeexecutor -d --restart=on-failure --name="listen_"$3"" -e ORDER="listen_"$3"" -e CONFIG="not_passed" -e EXCHANGE="$1" -e SUBACCOUNT="$2"
  #pyrun tradeexecutor -it --restart=on-failure --name="listen_"$3"" -e ORDER="listen_"$3"" -e CONFIG="not_passed" -e EXCHANGE="ftx" -e SUBACCOUNT="debug"
  echo "launched pyrun_listen "$coin""
  cd /tmp/tradeexecutor/
}

pyrun_ux(){
	# removes those containers with the the IDs of all containers that have exited
	#pyrun ux -it --restart=on-failure --name=ux_worker
  pyrun ux -d --restart=on-failure --name=ux_worker
	echo "launched pyrun_ux"
}

pyrun_glp(){
	# removes those containers with the the IDs of all containers that have exited
	#pyrun ux -it --restart=on-failure --name=ux_worker
  pyrun tradeexecutor -it --name="tradeexecutor_glp" -e ORDER="$1" -e CONFIG="not_passed" -e EXCHANGE="$2" -e SUBACCOUNT="$3"
  echo "launched pyrun_glp "$ORDER""
}