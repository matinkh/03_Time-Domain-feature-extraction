function [] = exportPerson(accelerometerData, fid, ID, prune)
%EXPORTPERSON Export the stats of a person to a CSV file
%   EXPORTPERSON(accelerometerData, fid, filename, prune) This will take in a
%   patient, find the statistics about that person, and print them to the file.
%
%   Note: initStats() must be called prior to this function.
%
%   Inputs:
%       accelerometerData: All 3 axes of accelerometer data.
%
%       fid: File ID for the file to write to
%
%       ID: Whichever piece of info from the file is the unique identifier
%
%       prune: Optional argument. This refers to pruning the wear times to only
%       those that are greater than or equal to 10 hours. Default value is
%       false.

INTERVAL = 60;

% Find the vector magnitude at each time point. These will be used for finding
% the wear versus nonwear.
accelerometerData_sq = accelerometerData .* accelerometerData;
% sum(..., 2) means take the sum across the row
VM = sqrt(sum(accelerometerData_sq, 2));

% Default value for prune is false
if nargin < 4
    prune = false;
end

wearTimes = findWearTimes(VM, true, prune);

% If there are no wear times skip this person.
if size(wearTimes, 1) == 0
    return;
end

% Write the identifying information
fprintf(fid, '%d,', ID);

% Find the axis magnitude proportion such as
% axis1/sqrt(axis1^2 axis2^2 axis3^2))
magnitudes = zeros(3, 1);
for i = 1:3
    axis = accelerometerData(:, i);
    for j = 1:size(wearTimes, 1);
        startpos = min((wearTimes(j, 1) * INTERVAL) + 1, length(axis));
        endpos = min(wearTimes(j,2) * INTERVAL, length(axis));

        magnitudes(i) = magnitudes(i) + sum(axis(startpos:endpos));
    end
end

% Write the proportions
totalMagnitude = sqrt(magnitudes(1)^2 + ...
                      magnitudes(2)^2 + ...
                      magnitudes(3)^2);
for i = 1:3
    fprintf(fid, '%.3f,', magnitudes(i) / totalMagnitude);
end

% Run for every axis
for i = 1:3
    axis = accelerometerData(:, i);
    bouts = activeWearTimes(axis, wearTimes);

    % beginning time of 0 for now until parsing for begin time is added.
    % therefore ignore all stats about morning/afternoon/evening
    stats = findStatistics(wearTimes, bouts, axis);
    values = double(stats(1, :));

    % We do not want an nan, instead replace it with zero
    values(isnan(values)) = 0;

    % write the actual stats
    fprintf(fid, '%.3f,', values);
end

% Run for the vector magnitude
bouts = activeWearTimes(VM, wearTimes);

stats = findStatistics(wearTimes, bouts, VM);
values = double(stats(1, :));
values(isnan(values)) = 0;
fprintf(fid, '%.3f,', values(1:end-1));
fprintf(fid, '%.3f\n', values(end));
