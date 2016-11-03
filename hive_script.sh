#!/bin/sh

# Setting some params from base_script.sh
ClusterUsername=$1
ClusterPassword=$2
DatabaseSize=$3
SingleQueryRun=$4
QueryNumber=$5

# Checking if git is installed
git --version
if [ $? -ne 0 ]; then
	echo "Installing git..."
	sudo apt-get -y install git
fi

# Check if hive-testbench is already present
testbench=/home/${ClusterUsername}/hive-testbench
echo "Checking if the hive-testbench is present .."
if [ -d "$testbench" ]; then
	echo "hive-testbench exists. Removing the testbench."
	rm -rf ${testbench}
fi

echo "Cloning the hive-testbench"
git clone https://github.com/hdinsight/HivePerformanceAutomation ${testbench}


chmod -R 777 $testbench
chmod -R a+x $testbench/*.sh

# go to tpch-scripts to run the script
cd $testbench/tpch-scripts
if [ "$SingleQueryRun" = true ]; then
	echo "Running the single query: $QueryNumber "
	./TpchSingleQueryExecute.sh ${DatabaseSize} ${QueryNumber}
else
	echo "Running the entire suite of 22 queries."
	./RunQueriesAndCollectPATData.sh ${DatabaseSize} ${ClusterPassword}
fi

cd ..
mkdir final_result
cp $testbench/run_*/logs/query_times.csv $testbench/final_result/

if [ $? -ne 0 ]; then
	echo "The result copying failed. Aborting."
else
	echo "The result is copied in the final_result"
fi