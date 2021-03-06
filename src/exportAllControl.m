function [] = exportAllControl( directory, outputFile )
%EXPORTALL Export all the people in the given directory
%   EXPORTALL(directory, outputFile) Go through the directory provided
%   assuming that every csv file is one patients data. Any file that has an
%   extension other than csv is ignored.
%
%   This will extract the statistics for the control time as indicated by
%   the CSVs themselves.
%
%   Inputs:
%       directory: The directory to go through containing the csv files.
%
%       outputFile: Optional argument for the name of the output file. If
%       no argument is specified the default value is
%       'allpeople_exported_control.csv'


% Vector containing the descriptions of the stats found
global stats_names

% open before we create the file we are going to write to
files = dir(directory);

% If there is no name for the output file given then use this default
if ~exist('outputFile', 'var')
    outputFile = 'allpeople_exported_control.csv';
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

        % We need all the data, how to sort it chronologically, the offset
        % in seconds for when the walk started, and the duration of the walk.
        data = double(accDataset(:, {'sortorder', ...
                                     'axis1', ...
                                     'axis2', ...
                                     'axis3' }));

        % When does the walk start and end
        walkStart = accDataset.w400_start_sortorder(1);

        if isnan(walkStart)
            fprintf(' no walk time for this file, skipping.\n');
            continue;
        end

        % Give them individial names
        walkTimeMins = accDataset.walk_min_w400(1);
        walkTimeSeconds = accDataset.walk_sec_w400(1);
        walkTimeTotal = (walkTimeMins*60) + walkTimeSeconds;
        walkEnd = walkStart + walkTimeTotal;


        % Put it in chronological order i.e. sort by the sortorder column
        data = sortrows(data, 1);

        % Remove all the data that is not part of the control time
        data = data(walkStart:walkEnd, :);

        % Export the this participant to the CSV
        % 2:4 because col 1 is the sortorder
        exportPersonControl(data(:, 2:4), fid, accDataset.pid(1));

        fprintf(' done.\n');
    else
        fprintf(' just kidding. Not a CSV file.\n');
    end
end

fclose(fid);

fprintf('---------------------------------\n');
fprintf('Done exporting all the CSV files.\n');

fprintf('Exporting took %f seconds\n', toc);
