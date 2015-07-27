#!/usr/bin/python

"""
This script will merge one of the output CSV files with its corresponding data
from the labeled data CSV.
"""

def buildLabelDictionary(labelFileName):
    """
    buildLabelDictionary(labelFileName) -> dictionary

    Build a dictionary where the key is the PID and the value is the list of
    values from the labels file, excluding the PID. The dictionary is returned.
    A return value of an empty dictionary indicates an error.
    """

    labelsDictionary = {}

    with open(labelFileName, 'r') as labelFile:
        # Names of all the columns
        labels = labelFile.readline().strip().split(',')

        # Find which column will be they key for our mapping
        PID_COL = labels.index('pid')

        for line in labelFile:
            # Get the list of information about this participant
            cols = line.strip().split(',')

            # This makes the PID the key and the list of values the value in the
            # dictionary. It also removes the PID from the list of values.
            pid = cols[PID_COL]
            labelsDictionary[pid] = cols[:PID_COL] + cols[PID_COL+1:]

    return labelsDictionary

def merge(filename, outputFilename, labelHeaders, labelsDictionary):
    """
    merge(filename, outputFilename, labelHeaders, labelsDictionary)

    This function will perform what is essentially a join on the files on the
    pid. It will read "filename" line by line and join each participants
    information with its corresponding information in the dictionary. If there
    is no match for the pid in the dictionary the row is omitted.

    The information from the dictionary will be placed immediately following
    the pid column.
    """

    # All the PIDs we have information/labels for
    validPIDs = labelsDictionary.keys()

    with open(filename, 'r') as dataFile, \
         open(outputFilename, 'w') as outFile:

        dataHeaders = dataFile.readline().strip().split(',')

        # Participant == pid
        PID_COL = dataHeaders.index('Participant')

        # Write the header row for the new CSV
        newHeader = dataHeaders[:PID_COL+1] + \
                    labelHeaders + \
                    dataHeaders[PID_COL+1:]
        outFile.write(','.join(newHeader) + '\n')

        for line in dataFile:
            stats = line.strip().split(',')
            pid = stats[PID_COL]

            # This person does not have a matching row in the labeled file, so
            # skip them and write nothing to the new output file
            if pid not in validPIDs:
                continue

            labeledStats = labelsDictionary[pid]
            newStats = stats[:PID_COL+1] + labeledStats + stats[PID_COL+1:]

            outFile.write(','.join(newStats) + '\n')

if __name__ == '__main__':
    import sys

    # After this error check we assume that arguments 1:len(sys.argv) are the
    # files to be merged with the labels
    if len(sys.argv) < 2:
        sys.stderr.write("Must provide the file(s) to merge as [an] argument(s)\n")
        sys.exit(1)

    # This is the file that we are getting the participants score, walk speed,
    # etc.
    LABELED_CSV = '../output/labeled_data.csv'

    # Get all the headers besides the PID
    with open(LABELED_CSV, 'r') as labelFile:
        labelHeaders = labelFile.readline().strip().split(',')
        labelHeaders.remove('pid')

    labeledDictionary = buildLabelDictionary(LABELED_CSV)

    for i in range(1, len(sys.argv)):
        # Do not merge the labeled CSV with anything
        if sys.argv[i] == LABELED_CSV:
            continue

        sys.stderr.write('Merging {}\n'.format(sys.argv[i]))
        # Remove the .csv, add '_merged.csv'
        outputFilename = sys.argv[i][:-4] + '_merged.csv'

        # Merge this file
        merge(sys.argv[i], outputFilename, labelHeaders, labeledDictionary)
