#!/bin/bash

# Setting some params from base_script.sh
ClusterUsername=$1

echo "<html>" > res.html
echo "<head>" >> res.html
echo "<style> table, tr, td { border: 1px solid black} </style>" >> res.html
echo "</head>" >> res.html
echo "<body>" >> res.html
echo "<table>" >> res.html
while read INPUT
do
        echo "<tr><td>${INPUT//,/</td><td>}</td></tr>"  >> res.html
done < /tmp/result.csv
echo "</table>" >> res.html
echo "</body>" >> res.html
echo "</html>" >> res.html
