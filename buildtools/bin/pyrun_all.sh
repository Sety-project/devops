#!/bin/bash
source ~/.bashrc

# Could use docker-compose at some point...
# Run histfeed
pyrun_histfeed $1

histfeed_status="$(docker container wait histfeed_worker_"$1")"
echo "Status code of histfeed_worker: "$histfeed_status""

# Run pfoptimizer only if histfeed returns 0
if [[ histfeed_status -eq 0 ]]; then
	pyrun_pfoptimizer $1 $2
fi;

# Run pnlexplain every hour. Removed -e USERNAME=$USERNAME
pyrun_riskpnl $1 $2
