#!/bin/bash
source ~/.bashrc

# because the run.sh demands them, all params must be passed incl optionals. "not_passed" will apply default from python script
gpa

docker_login
IS_DOCKER_RUNNING=`systemctl status docker | grep Active | grep running | wc -l`
if [[ $IS_DOCKER_RUNNING -eq 0 ]] ; then
sudo /bin/systemctl start docker.service
fi

docker rm $(docker ps --filter status=exited -q)
docker pull $PYTHON_REGISTRY/actualyield:latest

# they're in fact both running without detach falg...
docker run -e USERNAME=$USERNAME "${@}" \
-v ~/actualyield:/home/ubuntu/actualyield \
-v ~/actualyield/data:/home/ubuntu/actualyield/data \
-v ~/.cache/setyvault:/home/ubuntu/.cache/setyvault \
-v ~/actualyield/.streamlit:/home/ubuntu/actualyield/.streamlit \
-v /tmp:/tmp \
--network host $PYTHON_REGISTRY/actualyield:latest
