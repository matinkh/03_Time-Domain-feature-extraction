function [] = exportPerson( accelerometerData, fid, ID )
%EXPORTPERSON Export the stats of a person to a CSV file
%   EXPORTPERSON(accelerometerData, fid, ID) This will take in a patient, find
%   the statistics about that person, and print them to the file.
%
%   Inputs:
%       accelerometerData: All 3 axes of accelerometer data for the controlled
%       portion of the walk. This should be at most 10 minutes worth of data.
%
%       fid: File ID for the file to write to
%
%       ID: Whichever piece of info from the file is the nuique identifier

INTERVAL = 60;

% Find the vector magnitude at each time point. These will be used for finding
% the wear versus nonwear.
accelerometerData_sq = accelerometerData .* accelerometerData;
% sum(..., 2) means take the sum across the row
VM = sqrt(sum(accelerometerData_sq, 2));

% Write the identifying information
fprintf(fid, '%d,', ID);

% Find the axis magnitude proportion such as
% axis1/sqrt(axis1^2 axis2^2 axis3^2))
magnitudes = zeros(3, 1);
magnitudes(1) = sum(accelerometerData(:, 1));
magnitudes(2) = sum(accelerometerData(:, 2));
magnitudes(3) = sum(accelerometerData(:, 3));

% Write the proportions
totalMagnitude = sqrt(magnitudes(1)^2 + ...
                      magnitudes(2)^2 + ...
                      magnitudes(3)^2);
for i = 1:3
    fprintf(fid, '%.3f,', magnitudes(i) / totalMagnitude);
end

% The whole thing is 1 wear time.
wearTimes = [1 size(accelerometerData, 1)];

% The whole thing is the active wear time
activeWearTimes = [1 size(accelerometerData, 1)];

% Run for every axis
for i = 1:3
    axis = accelerometerData(:, i);

    stats = findStatistics(wearTimes, activeWearTimes, axis);
    values = double(stats(1, :));

    % We do not want an nan, instead replace it with zero
    values(isnan(values)) = 0;

    % write the actual stats
    fprintf(fid, '%.3f,', values);
end

stats = findStatistics(wearTimes, activeWearTimes, VM);
values = double(stats(1, :));
values(isnan(values)) = 0;

fprintf(fid, '%.3f,', values(1:end-1));
fprintf(fid, '%.3f\n', values(end));
