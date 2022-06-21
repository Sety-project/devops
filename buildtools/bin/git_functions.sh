#!/bin/bash

source ~/Sety-project/devops/buildtools/bin/variables.sh

declare -A LINUX_TO_GIT_USER
LINUX_TO_GIT_USER=(["vic"]="mol86" ["david"]="daviidarr")

clone_repository() {
	# Creates and clones an existing git repo
	
	#Wraps the following :
	#mkdir repo
	#cd repo
	#git init
	#git remote add origin <url>
	#git fetch origin
	#git checkout master

	if [[ $# -ne 1 ]]; then
		echo "Please specify which repository to clone"
		return
	fi

	CURRENT_WKDIR=$(pwd)	
	
	if [[ $1 == "config" ]]; then
		NAMESPACE_PATH=/home/$USERNAME
	else
		NAMESPACE_PATH=/home/$USERNAME/$NAMESPACE
	fi
	
	NEW_REPO=$NAMESPACE_PATH/$1
	mkdir -p $NEW_REPO
	
	# Return if repository is not empty
	if [[ "$(ls -A $NEW_REPO)" ]]; then
		echo "repo is not empty, ignoring clone"
		return
	fi

	# Place in NAMESPACE REPOSITORY for cloning
	cd $NAMESPACE_PATH

	# Repo created and empty --> clone
	# Will fail if repo passed does not exist
	echo "Trying to clone --> " git@$GIT_REPO:$NAMESPACE/$1.git
	git clone git@$GIT_REPO:$NAMESPACE/$1.git

        # Delete created repo and return on failure
	if [[ $? -ne 0 ]]; then
		rm -rf $NEW_REPO
		echo -e "\nCould not clone repository $1. Please specify a valid repository name from https://github.com/Sety-project"
        	cd $CURRENT_WKDIR
       	return
	fi

	# Replaces user where it was
	cd $CURRENT_WKDIR
	echo -e "\nSuccesfully cloned repository $1"
}

get_git_project_id() {
   if [[ $# -eq 1 ]] ; then
        OWNER=$NAMESPACE
        PROJECT=$1
   else
       PROJECT=$1
       OWNER=$2
   fi

   curl -u "${LINUX_TO_GIT_USER[$USERNAME]}":$GIT_PAT https://api.github.com/repos/$OWNER/$PROJECT | jq -r '.id'
}

get_git_user_id() {
    curl -u "${LINUX_TO_GIT_USER[$1]}":$GIT_PAT https://api.github.com/users/"${LINUX_TO_GIT_USER[$1]}" | jq -r '.id'
}

gs(){
	git status
}

gp(){
	git pull
}

gpa(){
	jpl && gp
	j devops && gp
	j research &&  gp
}


#curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/mol86/pylibs
#curl -s -X GET --header "PRIVATE-TOKEN: $GITLAB_TOKEN" https://api.github.com/repos/mol86/pylibs

#curl -X POST -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/Sety-project/pylibs/issues -d '{"title":"GitHub REST API","body":"Testing GitHub API","assignees":["mol86"],"milestone":1,"labels":["test"]}'
#curl -X POST -H "Authorization: Bearer $GITHUB_APP_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/Sety-project/pylibs/issues -d '{"title":"GitHub REST API","body":"Testing GitHub API","assignees":["mol86"],"milestone":1,"labels":["test"]}'


#curl \
#  -X POST \
#  -H "Accept: application/vnd.github.v3+json" \
#  https://api.github.com/repos/OWNER/REPO/issues \
#  -d '{"title":"Found a bug","body":"I'm having a problem with this.","assignees":["octocat"],"milestone":1,"labels":["bug"]}'





#GITHUB_APP_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiAiMTk5MzU5IiwgInN1YiI6ICJtb2w4NiIsICJpYXQiOiAxNjUyMjA1MzI2LCAiZXhwIjogMTY1MjIwNTkwNn0.ndjyaTLBAbl3fh8ufHynXp2BgJHmhs_OvDZMD141nrzP81EQQK6k2mnt2Oz9c6qljdKMfwtA0LAXbHMpAFQAKTQkMQLQgdwo4B7GKV92tAQ9F246UKymOPl7RNA0Ai52-6OEDxMCSZAcOKZpd20aYzXLEuEqHntLuax81VonLxqBUN-EloHVE3cB4kl6zSb2uQmfvyzqhqJBQDr1UlpWnMx7AKKNK4IG4hHQJOd9jlaMoVzyJqIVm_kltcadCuqFefJ86R8FKQD4TrYDjr0N15yxscScu4BI8tnRccOo7uy_SNZV-A3QBpOIOr3yLeg0NcKh0qiqkvf05z1xHuq3dw

#curl -i -X GET -H "Authorization: Bearer $GITHUB_APP_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/app/installations

#curl -i -X GET -H "Authorization: Bearer $GITHUB_APP_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/app/orgs/Sety-project/pylibs



#curl -i -H "Authorization: Bearer $GITHUB_APP_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/app                             # WORKS WHEN JWT TOKEN IS VALID
#curl -i -H "Authorization: Bearer $GITHUB_APP_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/Sety-project/pylibs
#curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/Sety-project/pylibs

#GET ALL REPOSITORIES --> WORKS
#curl -u mol86:$GIT_PAT https://api.github.com/user
#curl -u mol86:$GIT_PAT https://api.github.com/repos/mol86/pylibs => does not work
#curl -u mol86:$GIT_PAT https://api.github.com/orgs/Sety-project/repos => WORKS

# GET A REPOSITORY --> WORKS
#curl -u mol86:$GIT_PAT https://api.github.com/repos/Sety-project/pylibs




#Message : Validation fails
#curl -u mol86:$GIT_PAT -X POST -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/Sety-project/pylibs/issues -d '{"title":"GitHub REST API","body":"Testing GitHub API","assignees":["mol86"],"milestone":1,"labels":["test"]}'
