#!/bin/sh

git --version 

echo "This is the base script"

echo "Cluster: ${Cluster}.azurehdinsight.net"

ClusterSSH=${Cluster}-ssh.azurehdinsight.net
echo "Cluster ssh name: ${ClusterSSH}"

echo "ssh username: ${ClusterUsername}"
echo "ssh password: ${ClusterPassword}"

echo "Database selected: ${DatabaseSize}"

echo "Cloning the scripts repo ..."

git clone https://github.com/ameyk-msft/PerfScripts
cd PerfScripts

echo "Copying the hive script over to the cluster..."

sshpass -p ${ClusterPassword} scp -o "StrictHostKeyChecking no" hive_script.sh ${ClusterUsername}@${ClusterSSH}:/home/${ClusterUsername}/

sshpass -p ${ClusterPassword} ssh -o "StrictHostKeyChecking no" ${ClusterUsername}@${ClusterSSH} chmod a+x /home/${ClusterUsername}/hive_script.sh

sshpass -p ${ClusterPassword} ssh -o "StrictHostKeyChecking no" ${ClusterUsername}@${ClusterSSH} /home/${ClusterUsername}/hive_script.sh ${ClusterUsername} ${DatabaseSize}

if [ $? -ne 0 ]; then
	echo "Failed in hive_script. Exiting ..."
	exit 1
fi

echo "The hive_script completed!! Collecting the results..."
sshpass -p ${ClusterPassword} scp -o "StrictHostKeyChecking no" ${ClusterUsername}@${ClusterSSH}:/home/${ClusterUsername}/hive-testbench/logs/query_times.csv .
cat query_times.csv |  cut -f1,2 -d',' > result.csv

echo "Converting the result to html format ..."
chmod a+x convertToHtml.sh
./convertToHtml.sh