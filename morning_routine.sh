#!/bin/bash

source ~/sety/devops/buildtools/bin/bash_functions.sh

logs_location="/tmp/morning_log_$(date +%Y_%m_%d_%T).txt"

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
	echo local prunning in progress...
	docker system prune -af >> $logs_location 2>&1
}


cache_static(){
	pyrun staticdata -v ~/Static:/home/ec2-user/Static
}

prodbox(){
	ssh -i ~/Downloads/ec2-one.pem ec2-user@ec2-3-8-151-236.eu-west-2.compute.amazonaws.com -p 22
}

echo "Good morning!" >>  $logs_location
