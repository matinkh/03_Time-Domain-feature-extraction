function [ bouts ] = activeWearTimes( axis, wearTimes )
%ACTIVEWEARTIMES Given a wear time find the active regions inside it
%   Find all the active regions inside a given wear time.
%
%   Input:
%       axis: A single vector corresponding to the wear times input. This can
%       be either a single axis (x, y, z) or the vector magnitude vector
%       derived from all 3 axes.
%
%       wearTimes: The Nx2 matrix of interval wear times for the vector.
%
%   Output:
%       bouts: An Nx2 matrix representing the active bout intervals.

if size(wearTimes, 1) == 0
    bouts = [];
    return;
end

% Since we collapsed the wear time into minutes. It took the data from 1 Hz to
% 1/60 Hz.
INTERVAL = 60;

bouts = [];

% Unfortunately since we do not know ahead of time how many bouts there will be
% we cannot preallocate a matrix to save time.
for i = 1:size(wearTimes, 1)
    % Plus one since minute 0 starts at second 1, which is index 1.
    startpos = min(wearTimes(i, 1) * INTERVAL + 1, length(axis));
    endpos = min(wearTimes(i, 2) * INTERVAL, length(axis));

    bouts = [bouts; (identifyActiveAreas(axis(startpos:endpos)) + startpos)];
end
