#!/bin/bash

source ~/Sety-project/devops/buildtools/bin/bash_functions.sh
logs_location="/tmp/morning_log_$(date +%Y_%m_%d_%T).txt"
sudo systemctl start docker
pyrun_ux

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
  # this is to prune ECR but there is a lifecyle policy in place so not useful generally
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

prodbox(){
	ssh -i ~/.cache/setykeys/ec2-one.pem ec2-user@$ELASTIC_IPV4DNS -p 22
}
