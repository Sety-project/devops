#/bin/bash

export ECR_REGION=eu-west-2

pystop(){
  if [[ $1 != "all" ]]; then
 	  docker rm -f $(docker ps -aq --filter name=$1)
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

	if [[ $USERNAME == "ec2-user" ]]; then
	  docker run -d -e USERNAME=$USERNAME "${@}" \
	  -v ~/static:/home/ec2-user/static \
	  -v ~/mktdata:/home/ec2-user/mktdata \
	  -v ~/.cache/setyvault:/home/ec2-user/.cache/setyvault \
	  -v ~/config/prod:/home/ec2-user/config \
	  -v /tmp:/tmp \
	  --network host $PYTHON_REGISTRY/$PYTHON_PROJECT:latest
	else
	  docker run -it -e USERNAME=$USERNAME "${@}" \
	  -v ~/static:/home/ec2-user/static \
	  -v ~/mktdata:/home/ec2-user/mktdata \
	  -v ~/.cache/setyvault:/home/ec2-user/.cache/setyvault \
	  -v ~/config/prod:/home/ec2-user/config \
	  -v /tmp:/tmp \
	  --network host $PYTHON_REGISTRY/$PYTHON_PROJECT:latest
	fi
}

#################################
# For calls on the EC2 instance #
#################################

pyrun_static(){
	pyrun staticdata --rm --name=static_worker
	echo "ran pyrun_static"
}

pyrun_histfeed(){
	pyrun histfeed --rm --name=histfeed_worker \
	-e EXCHANGE="ftx" \
	-e RUN_TYPE="build" \
	-e UNIVERSE="all" \
	-e NB_DAYS="not_passed"
  echo "ran pyrun_histfeed"
}

pyrun_pfoptimizer(){
  echo "removing old shards"
  if [[ $USERNAME == "ec2-user" ]]; then
    DIRNAME=~/config/prod/pfoptimizer
  else
    DIRNAME=~/config/pfoptimizer
  fi
  find $DIRNAME -name "weight_shard_*" -exec rm -f {} \;

	pyrun pfoptimizer --rm --name=pfoptimizer_worker \
	-e ORDER="sysperp" \
	-e EXCHANGE="ftx" \
	-e TYPE="not_passed" \
	-e SUBACCOUNT="debug" \
	-e depth="not_passed" \
	-e config="not_passed"
	echo "ran pyrun_pfoptimizer"
}

pyrun_riskpnl(){
	pyrun riskpnl --rm --name=riskpnl_worker \
	-e RUN_TYPE="plex" \
	-e EXCHANGE="ftx" \
	-e SUBACCOUNT="debug" \
	-e NB_RUNS="not_passed" \
	-e $PERIOD="not_passed" \
	-e $DIRNAME="not_passed" \
	-e FILENAME="not_passed" \
	-e $CONFIG="not_passed"
	echo "ran pyrun_riskpnl"
}

pyrun_tradeexecutor(){
	# removes those containers with the the IDs of all containers that have exited
	if [[ $USERNAME == "ec2-user" ]]; then
    DIRNAME="/home/$USERNAME/config/prod/pfoptimizer"
  else
    DIRNAME="/home/$USERNAME/config/pfoptimizer"
  fi
	for order in $DIRNAME/weight_shard_*; do
	  i=$(grep -oP '_\K.*?(?=.csv)' <<< $order)
	  echo "tradeexecutor_$i $USERNAME"
    pyrun tradeexecutor --restart=on-failure --name="tradeexecutor_$i"\
    -e ORDER=$order \
    -e CONFIG="prod" \
    -e EXCHANGE="ftx" \
    -e SUBACCOUNT="debug"
    echo "ran pyrun_tradeexecutor"
  done
}

pyrun_ux(){
	# removes those containers with the the IDs of all containers that have exited
	#docker run -it --restart=on-failure -e DOCKER_IMAGE=helloworld -v /var/run/docker.sock:/var/run/docker.sock 878533356457.dkr.ecr.eu-west-2.amazonaws.com/ux
	#docker run -it --restart=on-failure --entrypoint=bash -v /var/run/docker.sock:/var/run/docker.sock 878533356457.dkr.ecr.eu-west-2.amazonaws.com/ux
	pyrun ux --restart=on-failure --name=ux_worker
	echo "ran pyrun_ux"
}