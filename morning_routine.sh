#!/bin/bash

logs_location="/tmp/morning_log_$(date +%Y_%m_%d_%T).txt"

export PYTHON_REGISTRY="878533356457.dkr.ecr.eu-west-2.amazonaws.com"     # Sety AWS
export ECR_REGION=eu-west-2
export REPO_LIST=$(aws ecr describe-repositories --region $ECR_REGION --query "repositories[].repositoryName" --output text)

# export PYTHON_BUILD_IMAGE="${PYTHON_REGISTRY}/pybuild:latest"

aws_login (){
	aws ecr get-login-password --region $ECR_REGION --profile default
}

docker_login (){
	aws_login | docker login --username AWS --password-stdin $PYTHON_REGISTRY
}

docker_pull (){
	docker_login
	for repo in $REPO_LIST; do
		docker pull $PYTHON_REGISTRY/$repo:latest
	done
}

prune_ecr(){
	for repo in $REPO_LIST; do
		#echo "list untagged images for $repo"
		IMAGES_TO_DELETE=$(aws ecr list-images --region $ECR_REGION --repository-name $repo --filter "tagStatus=UNTAGGED" --query 'imageIds[*]' --output json)
		if [ "$IMAGES_TO_DELETE" != "[]" ]; then
			echo "deleting untagged images from repository" $repo
			aws ecr batch-delete-image --region $ECR_REGION --repository-name $repo --image-ids "$IMAGES_TO_DELETE" || true
		fi
	done
}

prune_local(){
	echo todo
}

pyrun() {
	docker_login
	PYTHON_PROJECT=`pwd | sed 's#.*/##'`
	if [ $# -ne 0 ]
	then
	PYTHON_PROJECT=$1
	shift
	fi
	IS_DOCKER_RUNNING=`systemctl status docker | grep Active | grep running | wc -l`
	if [[ $IS_DOCKER_RUNNING -eq 0 ]] ; then 
	sudo /bin/systemctl start docker.service
	fi
	docker pull $PYTHON_REGISTRY/$PYTHON_PROJECT:latest
	
	echo voici mes params : "${@}"
	docker run -it "${@}" --network host $PYTHON_REGISTRY/$PYTHON_PROJECT:latest 
}

echo "Good morning!" >>  $logs_location
