#!/usr/bin/python
# Run this BEFORE addWalkTimeToCSV and AFTER the Matlab scrpit exportAll
# This script requires linux commands, dont run on windows

from subprocess import Popen, PIPE
import os, sys

if "-vm" in sys.argv:
    STAT_CSV = 'allpeopleVM.csv'
else:
    STAT_CSV = 'allpeople.csv'

# The new csv file
csvFile = open('all_participants_statistics.csv', 'w')

# Add the header and insert the category label
oldCSV = open(STAT_CSV, 'r')
header = oldCSV.readline().strip().split(',')
csvFile.write('%s,%s,%s\n' % (','.join(header[:1]), 'category', ','.join(header[1:])))

# Get the uniq label names
os.system('cut %s -f 1 -d , | uniq > %s' % (STAT_CSV, 'unique.txt'))

# for every line in the csv file, search for the corresponding person in the
# categories file and extract the category. Then add it to the CSV.
peopleCSV = open('unique.txt', 'r')
peopleCSV.readline() # read the 'participant' label
for person in peopleCSV:
    person = person.strip()
    # the shell command
    command = 'grep -ir %s %s' % (person, STAT_CSV)

    # run it and get the output
    p = Popen(command, shell=True, stdout=PIPE, stderr=PIPE)
    out, err = p.communicate()
    allRows = out.strip()

    # the shell command
    command = 'grep -ir %s %s | cut -f 4 -d ,' % (person, 'Labeled_participants\ v2.csv')

    # run it and get the output
    p = Popen(command, shell=True, stdout=PIPE, stderr=PIPE)
    out, err = p.communicate()
    category = out.strip()
    if category is '':
        continue

    # split the output into each of the original lines
    lines = allRows.split('\n')
    for line in lines:
        fields = line.split(',')
        # add category to the line and write it to the new file
        #print '%s,%s,%s' % (','.join(fields[:1]), category, ','.join(fields[1:]))
        csvFile.write('%s,%s,%s\n' % (','.join(fields[:1]), category, ','.join(fields[1:])))

csvFile.close()
oldCSV.close()
peopleCSV.close()
