#!/bin/bash

clone_repository() {
	# Creates and clones an existing git repo
	
	#Wraps the following :
	#mkdir repo
	#cd repo
	#git init
	#git remote add origin <url>
	#git fetch origin
	#git checkout master

	CURRENT_WKDIR=$(pwd)
	NAMESPACE_PATH=/home/$USERNAME/$NAMESPACE
	NEW_REPO=$NAMESPACE_PATH/$1

	if [[ $# -ne 1 ]]; then
		echo "Please specify which repository to clone"
		return
	fi
	
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

