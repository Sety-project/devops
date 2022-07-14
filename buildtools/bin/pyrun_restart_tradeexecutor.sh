#!/bin/bash
source ~/.bashrc

# Could use docker-compose at some point...
# Run histfeed
echo "stop tradeexecutor***"
pystop tradeexecutor
echo "restart tradeexecutor on current shards"
pyrun tradeexecutor
