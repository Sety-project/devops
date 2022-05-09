#!/bin/bash

cache_static() {
	# Function to cache static_main.json from the ec2
	
	if [[ $# -eq 1 ]] ; then
		DATE=$1                                                                              
	else
		DATE=main
	fi

	CACHE_LOCATION=/home/$USERNAME/.cache/staticdata
	REMOTE_LOCATION=/home/$USERNAME/Static/StaticData
	STATIC_FILE=/home/$USERNAME/Static/StaticData/static_$DATE.json                                                        

	mkdir -p $CACHE_LOCATION                                                             
		                                                                         
	if test -f "$CACHE_LOCATION/$STATIC_FILE"; then                                       
		echo "$STATIC_FILE found."                                                  
		return                                                                           
	else                                                              
		COMMAND_OUTPUT=`scp -i ~/Downloads/ec2-one.pem ec2-user@ec2-3-8-151-236.eu-west-2.compute.amazonaws.com:$STATIC_FILE $CACHE_LOCATION/`
	fi                                                                                   
		                                                                         
	if [[ $? -eq 0 ]] ; then                                                             
		echo "Successfully downloaded $STATIC_FILE."                                 
	fi                                                                                   
}

cache_feed() {
	echo "TODO"
}

available_feed() {
	echo "TODO"
}

run_simulation() {
	echo "TODO"
}

