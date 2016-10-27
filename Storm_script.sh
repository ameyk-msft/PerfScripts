#!/bin/sh

echo "Running the storm script ..."

# Params from base_script.sh
Workers=$1
SpoutParallelism=$(($2 * $1))
BoltParallelism=$(($3 * $1))
RecordSize=$4
SpoutWrites=$5
MaxFileSize=$6
SpoutPending=$7
TopologyName=$8
ClusterUsername=$9
ClusterPassword=$10

# Clone the Storm sample
echo "Cloning the storm sample "
git --version 
if [ $? -ne 0 ]; then
	echo "Currenlty assuming its Ubuntu and installing git..."
	sudo apt-get -y install git
fi

Storm_Example_Dir="/home/${ClusterUsername}/Storm_Sample"
# Checking the storm example dir
if [ -d "$Storm_Example_Dir" ]; then
	echo "storm example dir exists. removing the dir"
	rm -rf $Storm_Example_Dir

fi

git clone https://github.com/hdinsight/storm-performance-automation Storm_Sample

if [ $? -ne 0 ]; then
	echo "git cloning failed."
	exit 1
fi

cd Storm_Sample

# Check if Maven is installed and install it if not.
which mvn > /dev/null 2>&1
if [ $? -ne 0 ]; then
        SKIP=0
        if [ -e "apache-maven-3.0.5-bin.tar.gz" ]; then
                SIZE=`du -b apache-maven-3.0.5-bin.tar.gz | cut -f 1`
                if [ $SIZE -eq 5144659 ]; then
                        SKIP=1
                fi
        fi
        if [ $SKIP -ne 1 ]; then
                echo "Maven not found, automatically installing it."
                curl -O http://www.us.apache.org/dist/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz 2> /dev/null
                if [ $? -ne 0 ]; then
                        echo "Failed to download Maven, check Internet connectivity and try again."
                        exit 1
                fi
        fi
        tar -zxf apache-maven-3.0.5-bin.tar.gz > /dev/null
        CWD=$(pwd)
        export MAVEN_HOME="$CWD/apache-maven-3.0.5"
        export PATH=$PATH:$MAVEN_HOME/bin
fi

#check if inotifywait is present. If not then install it.
which inotifywait > /dev/null 2>&1
if [ $? -ne 0 ]; then 
	sudo apt-get -y install inotify-tools
fi

#build the storm example 
mvn clean package

# get the storagepath
AdlsPath=$TopologyName$(date +'%m%d%I%M%S')

# Run the Storm example
storm jar target/org.apache.storm.hdfs.writebuffertest-0.1.jar org.apache.storm.hdfs.WriteTopology -workers $Workers -recordSize $RecordSize -spoutParallelism $SpoutParallelism -numTasksSpout $SpoutParallelism -boltParallelism $BoltParallelism -numTasksBolt $(($BoltParallelism * 2)) -fileRotationSize $MaxFileSize -fileBufferSize 4000000 -numRecords $SpoutWrites -maxSpoutPending $SpoutPending -topologyName $TopologyName -storageUrl "adl://adlsperf12dm7.azuredatalakestore.net" -storageFileDirPath $AdlsPath -numAckers $SpoutParallelism -sizeSyncPolicyEnabled

echo "Pausing the script for the Storm topology to come up ..."
sleep 1m

ISALIVE=$(storm list | tail -1)
echo $ISALIVE

while [ "$ISALIVE" != "No topologies running." ]
do
	echo "----- Pausing for 1 minute -----"
	sleep 1m
	ISALIVE=$(storm list | tail -1)
	echo $ISALIVE
done

echo "Storm topology finished: $ISALIVE"

# aggregating the result files from all nodes
RESULT_PATH=/home/${ClusterUsername}/result
if [ -d "${RESULT_PATH}" ]; then
	echo "Removing the existing result dir."
	sudo rm -rf ${RESULT_PATH}
fi
mkdir ${RESULT_PATH}
cd ~/

for hn in `cat ~/hostlist.txt`
do
        if [ -f ~/$TopologyName.txt ]; then
			rm ~/$TopologyName.txt
		fi
		sshpass -p "${ClusterPassword}" scp -o "StrictHostKeyChecking no" ${ClusterUsername}@$hn:/tmp/$TopologyName.txt .
		cat ~/$TopologyName.txt >> ${RESULT_PATH}/finalResult.txt
done

echo "Final result is aggregated"
# sort the final result and get the time.
cd ${RESULT_PATH}/

cat finalResult.txt | cut -f3 -d',' > pruned.txt

sort -g -r --output=sorted.txt pruned.txt

# TOPOLOGY_TIME=$(head -1 sorted.txt)

# echo "Time for topology to complete: $TOPOLOGY_TIME"






