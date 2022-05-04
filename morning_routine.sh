#!/bin/bash

logs_location="/tmp/morning_log_$(date +%Y_%m_%d_%T).txt"

export PYTHON_REGISTRY="848832660957.dkr.ecr.eu-west-2.amazonaws.com"
# export PYTHON_REGISTRY="683664628229.dkr.ecr.eu-west-1.amazonaws.com"
export ECR_REGION=eu-west-2
export REPOSITORY_NAME=helloworld

# export PYTHON_BUILD_IMAGE="${PYTHON_REGISTRY}/pybuild:latest"

aws_login (){
	aws ecr get-login-password --region $ECR_REGION
}

docker_login (){
	aws_login | docker login --username AWS --password-stdin $PYTHON_REGISTRY
}

docker_pull (){
	docker pull $PYTHON_REGISTRY/$REPOSITORY_NAME:latest
}

prune_ecr(){
	REPO_LIST=$(aws ecr describe-repositories --region $ECR_REGION --query "repositories[].repositoryName" --output text);
	for repo in $REPO_LIST; do
		#echo "list untagged images for $repo"
		IMAGES_TO_DELETE=$(aws ecr list-images --region $ECR_REGION --repository-name $repo --filter "tagStatus=UNTAGGED" --query 'imageIds[*]' --output json)
		if [ "$IMAGES_TO_DELETE" != "[]" ]; then
			echo "deleting untagged images from repository" $repo
			aws ecr batch-delete-image --region $ECR_REGION --repository-name $repo --image-ids "$IMAGES_TO_DELETE" || true
		fi
	done

	#IMAGES_TO_DELETE=$( aws ecr list-images --region $ECR_REGION --repository-name $REPOSITORY_NAME --filter "tagStatus=UNTAGGED" --query 'imageIds[*]' --output json )
	#aws ecr batch-delete-image --region $ECR_REGION --repository-name $REPOSITORY_NAME --image-ids "$IMAGES_TO_DELETE" || true
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
	fi
	IS_DOCKER_RUNNING=`systemctl status docker | grep Active | grep running | wc -l`
	if [[ $IS_DOCKER_RUNNING -eq 0 ]] ; then 
	sudo /bin/systemctl start docker.service
	fi
	docker pull $PYTHON_REGISTRY/$PYTHON_PROJECT:latest
	shift
	echo voici mes params : "${@}"
	docker run -it "${@}" --network host $PYTHON_REGISTRY/$PYTHON_PROJECT:latest 
}

echo "Good morning!" >>  $logs_location
