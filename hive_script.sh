#!/bin/sh

# Setting some params from base_script.sh
ClusterUsername=$1
ClusterPassword=$2
DatabaseSize=$3
SingleQueryRun=$4
QueryNumber=$5

echo "Cloning the hive-testbench"
# git clone https://github.com/hdinsight/HivePerformanceAutomation /home/${ClusterUsername}/hive-testbench

testbench=/home/${ClusterUsername}/hive-testbench

chmod -R 777 $testbench
chmod -R a+x $testbench/*.sh

# go to tpch-scripts to run the script
cd $testbench/tpch-scripts
if [ "$SingleQueryRun" = true ]; then
	echo "Running the single query: $QueryNumber "
	./TpchSingleQueryExecute.sh ${DatabaseSize} ${QueryNumber}
else
	echo "Running the entire suite of 22 queries."
	# ./RunQueriesAndCollectPATData.sh ${DatabaseSize} ${ClusterPassword}
fi





