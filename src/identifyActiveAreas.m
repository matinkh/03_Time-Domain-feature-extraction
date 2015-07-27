function activeAreas = identifyActiveAreas(axis, downtimeThreshold)
%IDENTIFYACTIVEAREAS Find all active regions of a single axis
%      IDENTIFYACTIVEAREAS(axis) Given a vector representing a single axis, or
%      part of an axis, from the accelerometer data it will identify the active
%      regions using certain heuristics. It returns an Nx2 matrix representing
%      the intervals of activity.
%      The new parameter, downtimeThreshold, is an alternative value for
%      MIN_CONSEQ_ZEROS

% Threshold values
MIN_ACTIVE = 10;            % at least 10 seconds of activity to be considered
MIN_CONSEQ_ZEROS = 30;      % must have 30 zeros in a row to be done with activity
MIN_ACTIVITY_VALUE = 2;     % if the count is below this value we ignore it as
                            %     if it was a zero

% Variables to help determine activities
activityBegin = 1;          % start of activity region, 1 not 0 for valid index
numConsecutiveZeros = 0;    % keep track of how many zeros in a row we've seen
numActiveSeconds = 0;       % keep track of how many active seconds
                            %   this window has had

% The Nx2 matrix that will hold all the active windows.
% The value of cell i,1 is the start time and i,2 is the end time and i is the
% row number
activeAreas = [];

% Use downtimeThreshold if it was defined
if exist('downtimeThreshold', 'var')
    MIN_CONSEQ_ZEROS = downtimeThreshold;
end

% This algorithm currently does not consider the ratio of zeros to nonzeros,
% only the number of consequtive zeros. This could potentially lead to a
% problem such as every 29 seconds there is one active spot, then after 10
% occurances of this (so 10*29 seconds later) there are finally 30 zeros. This
% would count as an active area. This is, however, not very likely in practice.
for i = 1:numel(axis)
    if axis(i) < MIN_ACTIVITY_VALUE
        % Increment before the "if" so we consider the new zero also
        numConsecutiveZeros = numConsecutiveZeros + 1;

        if numConsecutiveZeros > MIN_CONSEQ_ZEROS
            % We've reached the limit of zeros so add the row if it has enough
            % activity

            % End of the bout
            activityEnd = i - MIN_CONSEQ_ZEROS;

            % Find the counts per minute for the bout
            boutLength = activityEnd - activityBegin;
            totalActivity = sum(axis(activityBegin:activityEnd));
            countsPerMinute =  totalActivity * 60 / boutLength;

            if numActiveSeconds > MIN_ACTIVE && countsPerMinute >= 100
                activeAreas = [activeAreas; activityBegin activityEnd];
            end

            numActiveSeconds = 0;
        end
    else
        % If we just found a new active area
        if numActiveSeconds == 0
            activityBegin = i;
        end

        numActiveSeconds = numActiveSeconds + 1;
        numConsecutiveZeros = 0;   % reset by finding a nonzero value
    end
end
