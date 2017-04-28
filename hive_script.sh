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
git clone https://github.com/ameyk-msft/HivePerformanceAutomation ${testbench}
git checkout adlshiveperf


chmod -R 777 $testbench
chmod -R a+x $testbench/*.sh

# temporary workaround for query16 for HDI3.4 and below.
# cd $testbench/sample-queries-tpch
# sed -i '1i\'"set hive.auto.convert.join=false;" tpch_query16.sql
# echo "Adding the temporary workaround for Query 16"

# go to tpch-scripts to run the script
cd $testbench/bin
if [ "$SingleQueryRun" = true ]; then
	echo "Running the single query: $QueryNumber "
	./runSingleQueryLoop.sh tpch tpch_query${QueryNumber}.sql
else
	echo "Running the entire suite of 22 queries."
	./runQueries.sh tpch
fi

cd ..
mkdir final_result
cp $testbench/output/tpch/run_*/querytimes/query_times_*.csv $testbench/final_result/query_times.csv

if [ $? -ne 0 ]; then
	echo "The result copying failed. Aborting."
else
	echo "The result is copied in the final_result"
fi
