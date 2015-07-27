#!/usr/bin/python
import os, os.path, sys, re

# Walk the directory and perform the action function on each file.
def walkDirectory(directory, action):
    for root, dirs, files in os.walk(directory):
        for f in files:
            action(root, f)

# Remove the header information from the CSV file, as well as the quotes
# surrounding the values in some cases
def extractData(filepath, filename):
    if filename[-4:] != '.csv':
        print 'Not a CSV file, skipping'
        return
    elif os.path.isfile(filename):
        print 'File already exists, skipping'
        return

    fullpath = os.path.join(filepath, filename)
    print >> sys.stderr, 'Trying to open the file "{0}"'.format(fullpath)

    csv_file = open(fullpath, 'r')
    csv_text = csv_file.readlines()

    # put the output file in the LIFE directory
    target_filename = '../LIFE/' + filename
    output_file = open(target_filename, 'w');

    # This regex matches a pattern of ((digits surrounded by 0 or more
    # quotes), followed by 0 or 1 commas)
    regex = re.compile(r'("*\d+"*,?){1,5}')

    toWrite = []
    MB = 1024.0 * 1024.0
    file_size = os.path.getsize(fullpath) / MB
    print >> sys.stderr, '\tParsing the {:.2f}MB file and writing to new file'.format(file_size)
    for line in csv_text:
        if re.match(regex, line):
            string_row = line.replace('"', '')
            toWrite.append(string_row)

    output_file.write(''.join(toWrite))
    output_file.flush()

    csv_file.close()
    output_file.close()

    output_file_size = os.path.getsize(target_filename) / MB
    print >> sys.stderr, '\tDone writing file "{0}" and it is now {1:.2f}MB'.format(target_filename, output_file_size)

if __name__ == "__main__":
    directory = '/home/stephen/Dropbox/Accelerometer data/LIFE example home data'
    walkDirectory(directory, extractData)
