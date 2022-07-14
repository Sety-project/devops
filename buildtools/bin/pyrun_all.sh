#!/bin/bash
source ~/.bashrc

# Could use docker-compose at some point...
# Run histfeed
pyrun_histfeed ftx

histfeed_status="$(docker container wait histfeed_worker_ftx)"
echo "Status code of histfeed_worker: $histfeed_status"

# Run pfoptimizer only if histfeed returns 0
if [[ histfeed_status -eq 0 ]]; then
	pyrun_pfoptimizer ftx SysPerp
	pyrun_pfoptimizer ftx debug
fi;

# Run pnlexplain every hour. Removed -e USERNAME=$USERNAME
pyrun_riskpnl ftx SysPerp
pyrun_riskpnl ftx debug

riskpnl_status="$(docker container wait riskpnl_worker)"
echo "Status code of riskpnl_worker: riskpnl_status"

# Run tradeexecutor only if pfoptimizer returns 0
# Run tradeexecutor if files date less than 1 hour ago... we can design what we want...
