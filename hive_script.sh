#!/bin/sh

# Setting some params from base_script.sh
ClusterUsername=$1
DatabaseSize=$2

echo "Cloning the hive-testbench"
# git clone https://github.com/hdinsight/HivePerformanceAutomation /home/${ClusterUsername}/hive-testbench

testbench=/home/${ClusterUsername}/hive-testbench

chmod -R 777 $testbench
chmod -R a+x $testbench/*.sh

# go to tpch-scripts to run the script
cd $testbench/tpch-scripts
echo "Running the queries ... "
./RunQueries.sh ${DatabaseSize}





