function activeWearTimes = findActiveWearTimes(axis, intervalTime)

SAMPLES_PER_SECOND = 1;
MINUTE = 60 * SAMPLES_PER_SECOND;
HOUR = 60 * MINUTE;
INTERVAL_TIME = MINUTE;

% If the user supplied an interval time then use it, otherwise default to 1 min
if ~exist('intervalTime', 'var')
    fprintf('No time interval supplied, so using the default of 1 minute\n');
    intervalTime = MINUTE;
end

% Defines the length of time which there must be "no activity" to be
% considered a nonwear time. Note that "no activity" includes the allowance
% interval defined below
WINDOW1_INTERVAL = 90;
WINDOW1_INTERVAL_MINUTES = 90 * MINUTE;

% The smaller moving window which will help identify wear vs. nonwear times
% by allowing a tolerance of some activity to be found in windows. Window2
% is used for upstream/downstream comparison. We break window1 into 3 smaller
% windows, window2's, which we use as follows: If there is an "active interval"
% in the current window2 as defined by the ARTIFACTUAL_ACTIVITY_INTERVAL, then
% if the next window2 AND the previous window2 are non-active, the window1 is
% considered nonwear.
WINDOW2_INTERVAL = 30;
WINDOW2_INTERVAL_MINUTES = 30 * MINUTE;

% The allowed number of nonzeros during the activity interval. A threshold of
% 0 means that if there is any nonzero then the interval is considered active.
ACTIVE_THRESHOLD = 0;

% If more than ACTIVE_THRESHOLD number of counts are found in this interval
% then the window2 this is found in will be counted as an active window.
ACTIVITY_INTERVAL = 2 * MINUTE;

if numel(axis) < WINDOW1_INTERVAL
    fprintf('The vector must have at least %d time points.', WINDOW1_INTERVAL);
    return
end

% Collapse the data into intervals
fprintf('Collapsing the data into intervals... ');
%intervalAxis = zeros(ceil(length(axis)/INTERVAL_TIME), 1);
intervalAxis = [];
i = 1;
j = 1;
while i < length(axis)
    endInterval = min(length(axis), i+INTERVAL_TIME);
    intervalSum = sum(axis(i:endInterval));
    intervalAxis(j) = intervalSum;
    j = j + 1;
    i = i + INTERVAL_TIME;
end
fprintf('Done.\n');

% Create a list of indicies where the values are greater than the threshold
% of activity
fprintf('Finding indicies where values are greater than the threshold... ');
nonzero = [];
for timepoint = 1:length(intervalAxis)
    if intervalAxis(timepoint) > ACTIVE_THRESHOLD
        nonzero = [nonzero; timepoint];
    end
end
fprintf('Done.\n');

% Find the intervals of nonzero elements
startPositions = [nonzero(1)];
endPositions = [];
previous = true;
for i = 2:numel(nonzero)
    % Hard coded 1 since it is checking if the two nonzero timepoints are
    % right next to eachother
    if nonzero(i) - nonzero(i-1) > 1
        startPositions = [startPositions; nonzero(i)];
        endPositions = [endPositions; nonzero(i-1)];
    end

    if i == numel(nonzero)
        endPositions = [endPositions; nonzero(i)];
    end
end

% The difference between start and end positions finds the size of the nonzero
% interval.
activeWindows = endPositions - startPositions;

fprintf('Doing upstream and downstream analysis... ');
for i = 1:length(activeWindows)
    if activeWindows(i) < ACTIVITY_INTERVAL
        upstream = '';
        downstream = '';

        % do upstream analysis
        upstreamStart = max(1, startPositions(i) - WINDOW2_INTERVAL);
        upstreamEnd = max(1, startPositions(i) - 1);

        if upstreamEnd - upstreamStart == 0
            upstream = 'nonwear';
        else
            if any(intervalAxis(upstreamStart:upstreamEnd))
                upstream = 'wear';
            else
                upstream = 'nonwear';
            end
        end

        % do downstream analysis
        downstreamStart = min(length(axis), startPositions(i) + 1);
        downstreamEnd = min(length(axis), startPositions(i) + WINDOW2_INTERVAL);

        if downstreamEnd - downstreamStart == 0
            downstream = 'nonwear';
        else
            if any(intervalAxis(upstreamStart:upstreamEnd))
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
fprintf('Done.\n');

% Keep only the intervals that were for wear time
fprintf('Finding intervals of wear time... ');
wearTimeStartPositions = [];
wearTimeEndPositions = [];
for i = 1:length(startPositions)
    if startPositions(i) ~= -1
        wearTimeStartPositions = [wearTimeStartPositions; startPositions(i)];
        wearTimeEndPositions = [wearTimeEndPositions; endPositions(i)];
    end
end
fprintf('Done.\n');


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

fprintf('Finding new starting/ending positions... ');
newStartingPositions = [];
newEndingPositions = [];
for i = 1:length(gapBeginnings)
    if gapBeginnings(i) ~= -1
        newStartingPositions = [newStartingPositions; gapBeginnings(i)];
    end
    if gapEndings(i) ~= -1
        newEndingPositions = [newEndingPositions; gapEndings(i)];
    end
end
fprintf('Done.\n');

fprintf('Saving active wear times... ');
activeWearTimes = zeros(length(intervalAxis), 1);
for i = 1:length(newStartingPositions)
    for j = newStartingPositions(i):newEndingPositions(i)
        activeWearTimes(j) = 1;
    end
end
fprintf('Done.\n');
