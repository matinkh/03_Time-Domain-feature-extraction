function [] = exportAll( directory, outputFile, prune )
%EXPORTALL Export all the people in the given directory
%   EXPORTALL(directory, outputFile, prune) Go through the directory provided
%   assuming that every csv file is one patients data. Any file that has an
%   extension other than csv is ignored.
%
%   Inputs:
%       directory: The directory to go through containing the csv files.
%
%       outputFile: Optional argument for the name of the output file. If
%       no argument is specified the default value is 'allpeople_exported.csv'
%
%       prune: Optional argument. This refers to pruning the wear times to only
%       those that are greater than or equal to 10 hours. Default value is
%       false.


% Vector containing the descriptions of the stats found
global stats_names

% open before we create the file we are going to write to
files = dir(directory);

% If there is no name for the output file given then use this default
if ~exist('outputFile', 'var')
    outputFile = 'allpeople_exported.csv';
end

% Set the default value for pruning
if nargin < 3
    prune = false;
end

fprintf('Everything will be exported to "%s"\n', outputFile);
fid = fopen(outputFile, 'w');

% Initialize the vector holding the names of the found stats
initStats();

% Write the header explaining the fields
fprintf(fid, '%s,', 'Participant');

% Write header for magnitude ratios
for i = 1:3
    fprintf(fid, 'axis%d_proportion,', i);
end

% Write header for axis 1 stats
for i = 1:numel(stats_names)
    fprintf(fid, 'axis1_%s,', stats_names{i});
end

% Write header for axis 2 stats
for i = 1:numel(stats_names)
    fprintf(fid, 'axis2_%s,', stats_names{i});
end

% Write header for axis 3 stats
for i = 1:numel(stats_names)
    fprintf(fid, 'axis3_%s,', stats_names{i});
end

% Write header for vector magnitude stats
for i = 1:numel(stats_names)-1
    fprintf(fid, 'VM_%s,', stats_names{i});
end

% Write the last one without the comma and with a newline
fprintf(fid, 'VM_%s\n', stats_names{numel(stats_names)});

fprintf('Exporting all CSV files in directory: "%s"\n', directory);
fprintf('-------------------------------------\n');

% Time how long it takes to export every file
tic;

% Go through all of the files in the directory
for file = files'
    % Only convert the csv files. This assumes that any file ending with .csv
    % is a file for us to convert.
    fullFileName = strcat(directory, '/', file.name);
    fprintf('About to export "%s"...', fullFileName);
    if length(file.name) > 4 && ...
            all(file.name(length(file.name)-3:length(file.name)) == '.csv')

        % inside the if here

        % Read the file as a dataset since it is heterogenous
        accDataset = dataset('File', fullFileName, 'Delimiter', ',');

        % We only want the three axes, and the order they should go in
        data = double(accDataset(:, {'sortorder', 'axis1', 'axis2', 'axis3'}));

        % Put it in chronological order i.e. sort by the sortorder column
        data = sortrows(data, 1);

        % Export the this participant to the CSV
        % -4 to remove the .csv and 2:4 because col 1 is the sortorder
        exportPerson(data(:, 2:4),  fid,  accDataset.pid(1), prune);

        fprintf(' done.\n');
    else
        fprintf(' just kidding. Not a CSV file.\n');
    end
end

fclose(fid);

fprintf('---------------------------------\n');
fprintf('Done exporting all the CSV files.\n');

fprintf('Exporting took %f seconds\n', toc);
