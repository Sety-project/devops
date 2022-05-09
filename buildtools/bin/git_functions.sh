#!/bin/bash

clone_repository() {
    
	NAMESPACE=Sety-project
	CURRENT_WKDIR=$(pwd)
	NAMESPACE_PATH=/home/$USERNAME/Sety-project
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

	# Tries to create the repository passed as parameter
	mkdir -p $NEW_REPO && cd $NEW_REPO

	# Repo created and empty --> clone
	git clone git@$GIT_REPO:$NAMESPACE/$1.git

	# Will fail if repo passed does not exist
	if [[ $? -ne 0 ]]; then
		rm -rf $NEW_REPO
		echo "Could not clone repository $1. Please specify a valid repository name from https://github.com/Sety-project"
	        echo $CURRENT_WKDIR
        	cd $CURRENT_WKDIR    
       	return
	fi

	# Replaces user where it was
	echo "Succesfully cloned repository $1"
	echo $CURRENT_WKDIR
	cd $CURRENT_WKDIR    
}

