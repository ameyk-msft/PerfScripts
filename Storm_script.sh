#!/bin/sh

echo "Running the storm script ..."

# Params from base_script.sh
SpoutParallelism=$1
BoltParallelism=$2
RecordSize=$3
SpoutWrites=$4
MaxFileSize=$5
SpoutPending=$6

# Clone the Storm sample
echo "Cloning the storm sample "
git clone https://github.com/ameyk-msft/Storm_Sample Storm_Sample

if [ $? -ne 0 ]; then
	echo "git cloning failed."
	exit 1
fi

cd Storm_Sample/src/microsoft.storm.writebuffertest

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

#build the storm example 
mvn clean package

# Run the Storm example
storm jar target/org.apache.storm.hdfs.writebuffertest-0.1.jar org.apache.storm.hdfs.WriteBufferTopology -workers 8 -recordSize $RecordSize -spoutParallelism $SpoutParallelism -numTasksSpout $SpoutParallelism -boltParallelism $BoltParallelism -numTasksBolt 512 -fileRotationSize 100 -fileBufferSize 4000000 -numRecords 10000000 -maxSpoutPending $SpoutPending -topologyName "ADLS_PERF_TOPOLOGY" -storageUrl "adl://adlsperf12dm7.azuredatalakestore.net" -storageFileDirPath "/amkama_1021/" -numAckers $SpoutParallelism -sizeSyncPolicyEnabled


