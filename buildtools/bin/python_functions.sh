#/bin/bash

export ECR_REGION=eu-west-2

pybuild(){
 	echo "todo"
}

pyrun() {
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

	docker pull $PYTHON_REGISTRY/$PYTHON_PROJECT:latest
        
	if [[ $USERNAME == "ec2-user" ]]; then
		docker run -d -e USERNAME=$USERNAME "${@}" --network host $PYTHON_REGISTRY/$PYTHON_PROJECT:latest
	else
		docker run -it -e USERNAME=$USERNAME "${@}" --network host $PYTHON_REGISTRY/$PYTHON_PROJECT:latest
	fi
}

#################################
# For calls on the EC2 instance #
#################################

pyrun_static(){
	pyrun staticdata --rm --name=static_worker -v ~/static:/home/ec2-user/static
}

pyrun_histfeed(){
	pyrun histfeed --rm --name=histfeed_worker -e EXCHANGE_NAME="ftx" -e RUN_TYPE="build" -e UNIVERSE="all" -v ~/.cache/setyvault:/home/ec2-user/.cache/setyvault -v ~/config/prod:/home/ec2-user/config -v ~/mktdata:/home/ec2-user/mktdata -v /tmp:/tmp
}

pyrun_pfoptimizer(){
  echo "removing old shards"
  if [[ $USERNAME == "ec2-user" ]]; then
    DIRNAME=~/config/prod/pfoptimizer
  else
    DIRNAME=~/config/pfoptimizer
  fi
  find $DIRNAME -name "weight_shard_*" -exec rm -f {} \;

	pyrun pfoptimizer --rm --name=pfoptimizer_worker -e ORDER="sysperp" -e EXCHANGE="ftx" -e SUBACCOUNT="debug" -v ~/mktdata:/home/ec2-user/mktdata -v ~/.cache/setyvault:/home/ec2-user/.cache/setyvault -v ~/config/prod:/home/ec2-user/config -v /tmp:/tmp
	echo "ran new weights"
}

pyrun_riskpnl(){
	pyrun riskpnl -e RUN_TYPE="plex" -e EXCHANGE="ftx" -e SUBACCOUNT="debug" -v ~/.cache/setyvault:/home/ec2-user/.cache/setyvault -v ~/config/prod:/home/ec2-user/config -v /tmp:/tmp
}

pyrun_tradeexecutor(){
	# removes those containers with the the IDs of all containers that have exited
	docker rm $(docker ps --filter status=exited -q)
	#if [[ $USERNAME == "ec2-user" ]]; then
  #  DIRNAME="/home/$USERNAME/config/prod/pfoptimizer"
  #else
  #  DIRNAME="/home/$USERNAME/config/pfoptimizer"
  #fi
	for order in $DIRNAME/weight_shard_*; do
	  i=$(grep -oP '_\K.*?(?=.csv)' <<< $order)
	  echo "tradeexecutor_$i"
    pyrun tradeexecutor --restart=on-failure --name="tradeexecutor_$i" -e ORDER=$order -e CONFIG="prod" -e EXCHANGE="ftx" -e SUBACCOUNT="debug" -v ~/.cache/setyvault:/home/ec2-user/.cache/setyvault -v ~/config/prod:/home/ec2-user/config -v /tmp:/tmp
  done

	# -v ~/mktdata:/home/ec2-user/mktdata unused
}

pyrun_ux(){
	# removes those containers with the the IDs of all containers that have exited
	docker rm $(docker ps --filter status=exited -q)
	#docker run -it --restart=on-failure -e DOCKER_IMAGE=helloworld -v /var/run/docker.sock:/var/run/docker.sock 878533356457.dkr.ecr.eu-west-2.amazonaws.com/ux
	#docker run -it --restart=on-failure --entrypoint=bash -v /var/run/docker.sock:/var/run/docker.sock 878533356457.dkr.ecr.eu-west-2.amazonaws.com/ux
	pyrun ux --restart=on-failure --name=ux_worker -v /var/run/docker.sock:/var/run/docker.sock -v ~/.cache/setyvault:/home/ec2-user/.cache/setyvault -v ~/config/prod:/home/ec2-user/config -v /tmp:/tmp
}
