#!/bin/bash

export ECR_REGION=eu-west-2

pybuild(){
 	echo "todo"
}

pyrun() {
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
		docker run -d "${@}" --network host $PYTHON_REGISTRY/$PYTHON_PROJECT:latest
	else
		docker run -it "${@}" --network host $PYTHON_REGISTRY/$PYTHON_PROJECT:latest
	fi
}

