echo "<html>" > res.html
echo "<head/>" >> res.html
echo "<body>" >> res.html
echo "<table>" >> res.html
while read INPUT
do
        echo "<tr><td>${INPUT//,/</td><td>}</td></tr>"  >> res.html
done < result.csv
echo "</table>" >> res.html
echo "</body>" >> res.html
echo "</html>" >> res.html
