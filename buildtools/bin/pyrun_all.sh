#!/bin/bash

gpa

# Could use docker-compose at some point...

# Run histfeed
docker run -d --rm --name=histfeed_worker -e EXCHANGE="ftx" -e RUN_TYPE="build" -e UNIVERSE="all" -v ~/.cache/setyvault:/home/ec2-user/.cache/setyvault -v ~/config/prod:/home/ec2-user/config -v ~/mktdata:/home/ec2-user/mktdata -v /tmp:/tmp --network host $PYTHON_REGISTRY/histfeed:latest

status_code="$(docker container wait histfeed_worker)"
echo "Status code of histfeed_worker: $status_code"

# Run pfoptimizer only if histfeed returns 0
if [[ $status_code -eq 0 ]]; then
	docker run -d --rm --name=pfoptimizer_worker -e ORDER="sysperp" -e EXCHANGE="ftx" -e SUBACCOUNT="debug" -e -v ~/mktdata:/home/ec2-user/mktdata -v ~/.cache/setyvault:/home/ec2-user/.cache/setyvault -v ~/config/prod:/home/ec2-user/config -v /tmp:/tmp $PYTHON_REGISTRY/pfoptimizer:latest
fi;

status_code="$(docker container wait pfoptimizer_worker)"
echo "Status code of pf_worker: $status_code"

# Run pnlexplain every hour. Removed -e USERNAME=$USERNAME
docker run -d --rm --name=riskpnl_worker -e RUN_TYPE="plex" -e EXCHANGE="ftx" -e SUBACCOUNT="debug" -v ~/.cache/setyvault:/home/ec2-user/.cache/setyvault -v ~/config/prod:/home/ec2-user/config -v /tmp:/tmp $PYTHON_REGISTRY/riskpnl:latest

status_code="$(docker container wait riskpnl_worker)"
echo "Status code of riskpnl_worker: $status_code"

# Run tradeexecutor only if pfoptimizer returns 0
# Run tradeexecutor if files date less than 1 hour ago... we can design what we want...
