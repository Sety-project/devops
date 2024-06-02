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
	STATIC_PATH=/home/ubuntu/Sety-project/static/staticdata
	STATIC_FILE=static_$DATE.json

	mkdir -p $CACHE_LOCATION                                                             
		                                                                         
	if test -f "$CACHE_LOCATION/$STATIC_FILE"; then                                       
		echo -e "$STATIC_FILE found\nReplacing old file..."                                                                     
	fi                                 
	
	#COMMAND_OUTPUT=`scp -i ~/.cache/setykeys/ec2-two.pem ubuntu@$ELASTIC_IPV4DNS:$STATIC_PATH/$STATIC_FILE $CACHE_LOCATION/`
	rsync -avh4z --progress -e  "ssh -i ~/.cache/setykeys/ec2-two.pem" ubuntu@$ELASTIC_IPV4DNS:$STATIC_PATH/$STATIC_FILE $CACHE_LOCATION/
	
	if [[ $? -eq 0 ]] ; then                                                             
		echo -e "\nSuccessfully downloaded $STATIC_FILE."                                 
	fi                                                                                   
}

cache_vault(){
	CACHE_LOCATION=/home/$USERNAME/.cache/setyvault
	VAULT_PATH=/home/ubuntu/Sety-project/.cache/setyvault
	
	mkdir -p $CACHE_LOCATION

	#COMMAND_OUTPUT=`scp -i ~/.cache/setykeys/ec2-two.pem ubuntu@$ELASTIC_IPV4DNS:$VAULT_PATH/* $CACHE_LOCATION/`
	rsync -avh4z --progress -e  "ssh -i ~/.cache/setykeys/ec2-two.pem" ubuntu@$ELASTIC_IPV4DNS:$VAULT_PATH/* $CACHE_LOCATION/
	
	if [[ $? -eq 0 ]] ; then             
		for entry in "$CACHE_LOCATION"/* ; do                                                
			echo -e "\nSuccessfully downloaded $entry"                                 
		done
	fi
}

cache_mktdata(){
	CACHE_LOCATION=/home/$USERNAME/mktdata
	MKTDATA_PATH=/home/ubuntu/Sety-project/mktdata
	
	mkdir -p $CACHE_LOCATION
	
	# use 4 IPv4, z compression, a send only differences, h human readable, v verbose
	rsync -avh4z --progress -e  "ssh -i ~/.cache/setykeys/ec2-two.pem" ubuntu@$ELASTIC_IPV4DNS:$MKTDATA_PATH/* $CACHE_LOCATION/

	if [[ $? -eq 0 ]] ; then             
		for entry in "$CACHE_LOCATION"/* ; do
			echo -e "\nSuccessfully downloaded $entry"                                 
		done
	fi
}

cache_config(){
	# Only caches ~/config/prod
	
	CACHE_LOCATION=/home/$USERNAME/config/prod
	CONFIG_PATH=/home/ubuntu/Sety-project/config/prod
	
	#rm -rf $CACHE_LOCATION
	mkdir -p $CACHE_LOCATION

	#COMMAND_OUTPUT=`scp -rp -i ~/.cache/setykeys/ec2-two.pem ubuntu@$ELASTIC_IPV4DNS:$CONFIG_PATH/* $CACHE_LOCATION/`
        rsync -avh4z --progress -e  "ssh -i ~/.cache/setykeys/ec2-two.pem" ubuntu@$ELASTIC_IPV4DNS:$CONFIG_PATH/* $CACHE_LOCATION/

	if [[ $? -eq 0 ]] ; then
		for entry in "$CACHE_LOCATION"/* ; do
			echo -e "\nSuccessfully downloaded $entry"                                 
		done
	fi
}

cache_tmp(){
  # go to some existing directory to avoid: https://serverfault.com/questions/591743/rsync-getcwd-no-such-file-or-directory-2
  cd ~

	# Caches all tmp app folders
	apps="histfeed tradeexecutor pfoptimizer riskpnl ux"
	
	if [[ $# -ne 0 ]] ; then
		apps="$@"
	fi
	
	for app in $apps; do
		CACHE_LOCATION=/tmp/prod/$app
		CONFIG_PATH=/tmp/$app
	
		rm -rf $CACHE_LOCATION
		mkdir -p $CACHE_LOCATION

		rsync -avh4z --progress -e  "ssh -i ~/.cache/setykeys/ec2-two.pem" ubuntu@$ELASTIC_IPV4DNS:$CONFIG_PATH/* $CACHE_LOCATION/

		if [[ $? -eq 0 ]] ; then
			for entry in "$CACHE_LOCATION"/* ; do
				echo -e "\nSuccessfully downloaded $entry"                                 
			done
		fi
	done

	jtt
}

cache_all() {
	cache_static
	cache_mktdata
	cache_config
	cache_tmp
}

available_feed() {
	echo "TODO"
}

run_simulation() {
	echo "TODO"
}
sync_ec2() {
    scp -i ~/.cache/setykeys/ec2-two.pem -r ubuntu@ec2-13-42-75-179.eu-west-2.compute.amazonaws.com:/home/ubuntu/deribitvolarb/logs /home/user/deribitvolarb
#    scp -i ~/.cache/setykeys/ec2-two.pem -r ubuntu@ec2-13-42-75-179.eu-west-2.compute.amazonaws.com:/home/ubuntu/actualyield /home/user/actualyield/remote_data
    aws s3 cp s3://actualyield /home/user/actualyield/remote_data --recursive
}