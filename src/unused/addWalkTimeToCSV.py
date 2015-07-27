#!/usr/bin/python
# This is to be run AFTER the addCategoryToCSV.py
# This script requires linux commands, dont run on windows

from subprocess import Popen, PIPE
import os, sys

if "-vm" in sys.argv:
    STAT_CSV = 'allpeopleVM.csv'
else:
    STAT_CSV = 'allpeople.csv'

OLD_CSV_FILENAME = 'all_participants_statistics.csv'
NEW_CSV_FILENAME = 'all_participants_statistics2.csv'
UNIQUE_NAMES = 'unique.txt'

# The new csv file
csvFile = open(NEW_CSV_FILENAME, 'w')

# Add the header and insert the category label
oldCSV = open(OLD_CSV_FILENAME, 'r')
header = oldCSV.readline().strip().split(',')
csvFile.write('%s,%s,%s\n' % (','.join(header[:3]), 'walkTime', ','.join(header[3:])))

# Get the uniq label names
os.system('cut %s -f 1 -d , | uniq > %s' % (STAT_CSV, UNIQUE_NAMES))

# for every line in the csv file, search for the corresponding person in the
# categories file and extract the category. Then add it to the CSV.
peopleCSV = open(UNIQUE_NAMES, 'r')
peopleCSV.readline() # read the 'participant' label
for person in peopleCSV:
    person = person.strip()
    # the shell command
    command = 'grep -ir %s %s' % (person, OLD_CSV_FILENAME)

    # run it and get the output
    p = Popen(command, shell=True, stdout=PIPE, stderr=PIPE)
    out, err = p.communicate()
    allRows = out.strip()

    # the shell command
    command = 'grep -ir %s %s | cut -f 6 -d ,' % (person, 'Labeled_participants\ v2.csv')

    # run it and get the output
    p = Popen(command, shell=True, stdout=PIPE, stderr=PIPE)
    out, err = p.communicate()
    walkTime = out.strip()
    if walkTime is '':
        continue

    # split the output into each of the original lines
    lines = allRows.split('\n')
    for line in lines:
        fields = line.split(',')
        # add walk time to the line and write it to the new file
        csvFile.write('%s,%s,%s\n' % (','.join(fields[:3]), walkTime, ','.join(fields[3:])))

csvFile.close()
oldCSV.close()
peopleCSV.close()

# cleanup
os.system('rm %s %s; mv %s %s' % (OLD_CSV_FILENAME, UNIQUE_NAMES, NEW_CSV_FILENAME, OLD_CSV_FILENAME))
