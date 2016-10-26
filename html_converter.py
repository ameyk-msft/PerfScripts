#!/usr/bin/python
import csv

csvFile = open('result.csv')#enter the csv filename
csvReader = csv.reader(csvFile)
csvData = list(csvReader)


with open('output.html', 'w') as html: #enter the output filename
    html.write('''<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.8.1/bootstrap-table.min.css">

<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
''')
    html.write('<table border="0" cellpadding="2" cellspacing="0" width="80%" style="border: #dcdcdc 1px solid;font-weight: bold;">\r')
    r = 0
    for row in csvData:
        if r == 0:
            html.write('\t<thead>\r\t\t<tr>\r')
            for col in row:
                html.write('\t\t\t<th data-sortable="true">' + col + '</th>\r')
            html.write('\t\t</tr>\r\t</thead>\r')
            html.write('\t<tbody>\r')
        else:
            html.write('\t\t<tr>\r')
            for col in row:
                html.write('\t\t\t<td align="center">' + col + '</td>\r')
            html.write('\t\t</tr>\r')

        r += 1
    html.write('\t</tbody>\r')
    html.write('</table>\r')

    html.write('''
<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"></script>

<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>

<!-- Latest compiled and minified JavaScript -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-table/1.8.1/bootstrap-table.min.js"></script>
''')
