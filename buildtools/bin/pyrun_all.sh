#!/bin/bash
source ~/.bashrc

gpa

# Could use docker-compose at some point...

# Run histfeed
pyrun_histfeed ftx

status_code="$(docker container wait histfeed_worker)"
echo "Status code of histfeed_worker: $status_code"

# Run pfoptimizer only if histfeed returns 0
if [[ $status_code -eq 0 ]]; then
	pyrun_pfoptimizer ftx SysPerp
	pyrun_pfoptimizer ftx debug
fi;

status_code="$(docker container wait pfoptimizer_worker)"
echo "Status code of pf_worker: $status_code"

# Run pnlexplain every hour. Removed -e USERNAME=$USERNAME
pyrun_riskpnl ftx SysPerp
pyrun_riskpnl ftx debug

status_code="$(docker container wait riskpnl_worker)"
echo "Status code of riskpnl_worker: $status_code"

# Run tradeexecutor only if pfoptimizer returns 0
# Run tradeexecutor if files date less than 1 hour ago... we can design what we want...
