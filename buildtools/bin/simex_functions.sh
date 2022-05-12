#!/bin/bash

cache_static() {
	# Function to cache static_main.json from the ec2
	# Will pull static_main.json or static_date if date is passed as argument
	
	if [[ $# -eq 1 ]] ; then
		DATE=$1                                                                              
	else
		DATE=main
	fi

	CACHE_LOCATION=/home/$USERNAME/.cache/staticdata
	REMOTE_LOCATION=/home/$USERNAME/static/staticdata
	STATIC_PATH=/home/ec2-user/static/staticdata                                                        
	STATIC_FILE=static_$DATE.json

	mkdir -p $CACHE_LOCATION                                                             
		                                                                         
	if test -f "$CACHE_LOCATION/$STATIC_FILE"; then                                       
		echo -e "$STATIC_FILE found\nReplacing old file..."                                                                     
	fi                                 
	
	COMMAND_OUTPUT=`scp -i ~/.cache/setykeys/ec2-one.pem ec2-user@ec2-3-8-151-236.eu-west-2.compute.amazonaws.com:$STATIC_PATH/$STATIC_FILE $CACHE_LOCATION/`
	                                                                                   	                                                                         
	if [[ $? -eq 0 ]] ; then                                                             
		echo "Successfully downloaded $STATIC_FILE."                                 
	fi                                                                                   
}

cache_vault(){
	CACHE_LOCATION=/home/$USERNAME/.cache/setyvault
	VAULT_PATH=/home/ec2-user/.cache/setyvault
	
	mkdir -p $CACHE_LOCATION

	COMMAND_OUTPUT=`scp -i ~/.cache/setykeys/ec2-one.pem ec2-user@ec2-3-8-151-236.eu-west-2.compute.amazonaws.com:$VAULT_PATH/* $CACHE_LOCATION/`

	if [[ $? -eq 0 ]] ; then             
		for entry in "$CACHE_LOCATION"/* ; do                                                
			echo "Successfully downloaded $entry"                                 
		done
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

