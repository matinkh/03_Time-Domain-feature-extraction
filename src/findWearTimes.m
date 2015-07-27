function [ wearTimes ] = findWearTimes(axis, interval, prune)
%FINDWEARTIMES Identify the times which the ActiGraph is being worn
%   FINDWEARTIMES(axis, interval) Given a vector representing a single axis
%   from the accelerometer data, or a vector formed by the vector magnitude
%   of all three axes, it will identify the times during which the device
%   was being worn. The current intervals are fixed.
%       Intervals:
%           Window1 = 90 minutes
%           Window2 = 30 minutes
%           Activity interval = 2 minutes
%
%       Inputs:
%           axis: The vector representing a single axis of actigraph data
%
%           interval: 0 (false) for output in vector representation and 1 (true)
%           for matrix
%
%           prune: True to remove wear times that are shorter then 10 hours,
%           false otherwise.
%
%       Output:
%           wearTimes:
%               Matrix: An Nx2 matrix where each row is a wear time interval
%                   e.g. [60, 270] means the interval starts at 60 minutes and
%                   ends are 270 minutes inclusive. To expand this back out
%                   into seconds

%                   startpos = min(wearTimes(i, 1) * 60 + 1, length(axis));
%                   endpos = min(wearTimes(i, 2) * 60, length(axis));
%
%                   multiply by 60 because that is the amount of samples
%                   per minute, hence the amount we collapse the data by to
%                   form an axis in terms of activity per minute for wear
%                   time calculation. Once this function becomes more
%                   gerneral/robust the 60 will change to
%
%                   samples_per_second * 60
%
%               Vector: An Nx1 matrix where each value represents a single data
%                   point from the condensed minute interval axis.
%                   Example: [1 1 1 1 0 0 0] means that minutes 1:4 were wear
%                   times, 5:7 were not. To reconstruct the original axis
%                   expand each data point into 60 (since each data point here
%                   represents one minute).

SAMPLES_PER_SECOND = 1;
MINUTE = 60 * SAMPLES_PER_SECOND;
HOUR = 60 * MINUTE;

%{
    Defines the length of time which there must be "no activity" to be
    considered a nonwear time. Note that "no activity" includes the allowance
    interval defined below
%}
WINDOW1_INTERVAL = 90;
% This would be used if we were not breaking the data into 1 minute chunks.
WINDOW1_INTERVAL_MINUTES = 90 * MINUTE;

%{
    The smaller moving window which will help identify wear vs. nonwear times
    by allowing a tolerance of some activity to be found in windows. Window2
    is used for upstream/downstream comparison. We break window1 into 3 smaller
    windows, each the size of window2, which we use as follows: If there is an
    "active interval" in the current window2 as defined by the ACTIVITY_INTERVAL,
    then if the next window2 AND the previous window2 are non-active, the window1
    is considered nonwear.
%}
WINDOW2_INTERVAL = 30;
% This would be used if we were not breaking the data into 1 minute chunks.
%WINDOW2_INTERVAL_MINUTES = 30 * MINUTE;

% The threshold that will constitue activity. When this value is 0 then any
% activity count, 1 or greater, will count as an active point.
ACTIVE_THRESHOLD = 0;

% How many minutes are allowed to have activity upstream or downstream and
% still be within an acceptable tolerance so that it would consititue nonwear
ACTIVE_STREAM_THRESHOLD = 2;

% If more than ACTIVE_THRESHOLD number of active points are found in this
% interval then the window2 this is found in will be counted as an active window.
ACTIVITY_INTERVAL = 2;
ACTIVITY_INTERVAL_MINUTES = 2 * MINUTE;

wearTimes = [];

% Ensure there are enough elements and that is it in fact a vector
if numel(axis) < WINDOW1_INTERVAL_MINUTES || ~isvector(axis)
    return
end

% Collapse the data into 1 minute intervals

numMinutes = ceil(length(axis) / MINUTE);
minuteAxis = zeros(numMinutes, 1);
for i = 1:numMinutes
    startMin = (i-1)*MINUTE + 1;
    
    % -1 so that we go from 1 to 60, 61 to 120, etc.
    endMin = min(length(axis), startMin + MINUTE - 1);
    
    minuteSum = sum(axis(startMin:endMin));
    minuteAxis(i) = minuteSum;
end

% Anything over threshold will be a 1 anything below (including values that
% were already zero) will be a zero. This will be used to determine how many
% minutes had activity upstream or downstream.
minuteAxisBool = minuteAxis > ACTIVE_THRESHOLD;

% Create a list of indicies where the values are greater than the threshold
% of activity
nonzero = find(minuteAxis);

% Find the intervals of nonzero elements
% If there are no nonzero elements then there is no chance of a wear time area
% so just return
if ~any(nonzero)
    return;
end

startPositions = [nonzero(1)];
endPositions = [];
for i = 2:numel(nonzero)
    % Hard coded 1 since it is checking if the two nonzero timepoints are
    % right next to eachother. This means we will not count a single contiguous
    % active area more than once.
    if nonzero(i) - nonzero(i-1) > 1
        startPositions = [startPositions; nonzero(i)];
        endPositions = [endPositions; nonzero(i-1)];
    end

end
endPositions = [endPositions; nonzero(numel(nonzero))];

% The difference between start and end positions finds the size of the nonzero
% interval.
activeWindows = endPositions - startPositions;

% Go through all of the found active windows doing upstream and downstream
% analysis. Eliminate the windows of nonwear, meaning where the only active
% part of the interval is the current window, but upstream and downstream are
% both inactive (aka 'nonwear').
for i = 1:length(activeWindows)
    % Need to look into why this if statement is even here. Seems to work the
    % same Without it. Consult the paper.
    % My thinking is that because anything over activity interval threshold
    % is by default considered wear time. The upstream/downstream analysis is
    % only for those areas that are not considered 'wear' time on their own.
    if activeWindows(i) < ACTIVITY_INTERVAL
        upstream = '';
        downstream = '';

        % do upstream analysis
        upstreamStart = max(1, startPositions(i) - WINDOW2_INTERVAL);
        upstreamEnd = max(1, startPositions(i) - 1);

        if upstreamEnd - upstreamStart == 0
            upstream = 'nonwear';
        else
            if sum(minuteAxisBool(upstreamStart:upstreamEnd)) > ACTIVE_STREAM_THRESHOLD
                upstream = 'wear';
            else
                upstream = 'nonwear';
            end
        end

        % do downstream analysis
        downstreamStart = min(length(minuteAxis), startPositions(i) + 1);
        downstreamEnd = min(length(minuteAxis),...
                            startPositions(i) + WINDOW2_INTERVAL);

        if downstreamEnd - downstreamStart == 0
            downstream = 'nonwear';
        else
            if sum(minuteAxisBool(downstreamStart:downstreamEnd)) > ACTIVE_STREAM_THRESHOLD
                downstream = 'wear';
            else
                downstream = 'nonwear';
            end
        end

        if strcmp(upstream, 'nonwear') && strcmp(downstream, 'nonwear')
            startPositions(i) = -1;
            endPositions(i) = -1;
        end
    end
end

% Keep only the intervals that were for wear time
wearTimeStartPositions = startPositions(startPositions ~= -1);
wearTimeEndPositions = endPositions(endPositions ~= -1);

% The first end time until the second start time is the first gap, and so on.
nonwearGaps = (wearTimeStartPositions(2:length(wearTimeStartPositions)) ...
              - wearTimeEndPositions(1:length(wearTimeEndPositions)-1));

gapBeginnings = wearTimeStartPositions(2:length(wearTimeStartPositions));
gapEndings = wearTimeEndPositions(1:length(nonwearGaps));

for i = 1:length(gapBeginnings)
    if nonwearGaps(i) < WINDOW1_INTERVAL
        gapBeginnings(i) = -1;
        gapEndings(i) = -1;
    end
end

gapBeginnings = [wearTimeStartPositions(1); gapBeginnings];
gapEndings = [gapEndings; wearTimeEndPositions(length(nonwearGaps)+1)];

newStartingPositions = gapBeginnings(gapBeginnings ~= -1);
newEndingPositions = gapEndings(gapEndings ~= -1);

if prune
    wearIntervals = newEndingPositions - newStartingPositions;
    % 10 * 60 because we are looking at a minute scale axis and we want
    % a 10 hour threshold
    aboveThreshold = wearIntervals >= 10 * 60;
    newStartingPositions = newStartingPositions(aboveThreshold);
    newEndingPositions = newEndingPositions(aboveThreshold);
end

% Consider the first 4 minute are "wear time". Then the correct
% interval would be SECONDS 1 until 240. But the interval would
% currently be reported as [1 4]. Therefore we need to make it
% [0 4] so that when we expand it again using
%
% start = (i, 1) * interval + 1 = 1
% end = (i, 2) * interval = 240
%
% Thus we subtract 1 from the beginning minute and leave the final minute
% the same.
if interval == 0
    % Start with all zeros, assuming there is no wear time
    wearTimes = zeros(length(minuteAxis),1);
    for i = 1:length(newStartingPositions)
        wearTimes(newStartingPositions(i)-1:newEndingPositions(i)) = 1;
    end
else
    % Add a row for each wear time interval
    wearTimes = zeros(length(newStartingPositions), 2);
    for i = 1:length(newStartingPositions)
        wearTimes(i, :) = [newStartingPositions(i)-1 newEndingPositions(i)];
    end
end
