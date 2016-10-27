#!/bin/bash

# Getting some params
CLUSTER=$1
USERNAME=$2
PASSWORD=$3


AMBCLUSTER=`curl --insecure --silent --user "$USERNAME:$PASSWORD" https://$CLUSTER.azurehdinsight.net/api/v1/clusters | sed -n -e 's/ *"cluster_name" : "\(.*\)",/\1/p'`
curl --insecure --silent --user "$USERNAME:$PASSWORD" https://stormadls2.azurehdinsight.net/api/v1/clusters/$AMBCLUSTER/hosts | sed -n -e 's/ *"host_name" : "\(.*\)"/\1/p' > ~/hostlist.txt
