#!/bin/bash
source ~/.bashrc

#echo "stop tradeexecutor***"
#pystop tradeexecutor
echo "start tradeexecutor on current shards"
pyrun_tradeexecutor $1 $2
