function [ stats ] = findStatistics( wearTimes, ...
                                     activeWearTimes, ...
                                     axis )
%FINDSTATISTICS Print out some interesting statistics of an axis of data
%       FINDSTATISTICS(wearTimes, activeWearTimes, axis)
%       Find the statstics we want to measure. We currently find the mean
%       and standard deviation of:
%           Number of bouts total across all wear times
%           Number of bouts in a wear time
%           Activity counts/min for the bouts in a wear time.
%               This means we find the average of each active area, and then
%               average those.
%           Length of a bout
%           Size of gaps between bouts.
%           Activity count total per wear time (raw sum)
%
%       Inputs:
%           wearTimes: The Nx2 matrix of wear time periods
%
%           activeWearTimes: The Nx2 matrix representing active periods of wear
%           AKA the bouts
%
%           axis: The vector of accelerometer data
%
%       Output:
%           stats: Dataset that will have a hold all of the statistics. This
%           allows key-value access to statistics, much like a map or
%           dictionary would provide.

%       Note: throughout this program the terms "bout" and "active area" are
%               used interchangably

% Variable names for the dataset for each person
global stats_names

if exist('stats_names', 'var') ~= 1
    initStats();
end

% Results
numWearTimes = 0;
numBoutsTotal = 0;

numBoutsPerWearTimeAvg = 0;
numBoutsPerWearTimeStd = 0;

activityCountsPerMinPerBoutAvg = 0;
activityCountsPerMinPerBoutStd = 0;

boutLengthAvg = 0;
boutLengthStd = 0;

numGapsBetweenBoutsAvg = 0;
numGapsBetweenBoutsStd = 0;

gapBetweenBoutsLengthAvg = 0;
gapBetweenBoutsLengthStd = 0;

activityCountPerWearTimeAvg = 0;
activityCountPerWearTimeStd = 0;

boutsCategorized = zeros(5, 1);
boutCategories = zeros(size(activeWearTimes, 1), 1);

% 50 buckets, where each bucket represents two minutes. Therefore if we have a
% 1.5 minute bout it goes in bucket one. If we had a 23 minute bout it goes in
% bucket 12. The 50th bucket represents 58+ minutes. The range for bucket 1 is
% (0, 2], bucket 2 is (2, 4], etc.
boutsPerBucket = zeros(30, 1);

% Keep the sum of the activity counts and the sum of the amount of time for
% each bucket as well. This will be used for finding the "half life" bucket
% and the counts/min up until that point.
activityPerBucket = zeros(30, 1);
secondsPerBucket = zeros(30, 1);

% Total number of bouts is just the total number of active periods we've found
numBoutsTotal = size(activeWearTimes, 1);

% The average number of bouts per wear time is just the total number of bouts
% divided by the number of wear times
numWearTimes = size(wearTimes, 1);
numBoutsPerWearTimeAvg = numBoutsTotal / numWearTimes;

%{
  We will find the average activity counts per minute per bout by first finding
  the activity count per minute of each bout then taking the average of those
  results.

  This vector will match one-to-one with the activeWearTimes matrix where each
  row in the activeWearTimes (corresponding to a bout interval) will have an
  average activity count per minute equal to the value in the vector at the
  same row.

 Active        Activity counts
 wear times    per min
 --------      -----
 |1   15|      |193|
 |24  40| ---> |508|
 |57  77|      |328|
 --------      -----
%}

% find the activity count/minute for each bout
% also find the bout lengths
%{
  Example:
    let sum(axis(startpos:endpos)) = 500 i.e. 500 activity count total over
        this interval
    let endpos - startpos = 30 i.e. this was a 30 second bout
    then the activity count/minute for this bout would be

    500 / 30 = X / 60
    X = 500 * 60 / 30
%}
activityCountsPerMin = zeros(numBoutsTotal, 1);
boutLengths = zeros(numBoutsTotal, 1);
for i = 1:numBoutsTotal
    % start and end time of bout
    startpos = activeWearTimes(i, 1);
    endpos = activeWearTimes(i, 2);

    % total activity count is just the sum over the length of the bout
    totalActivityCount = sum(axis(startpos:endpos));

    % plus 1 because its inclusive
    % consider startpos = 1 endpos = 2, then length = 1 when really it should
    % be 2 since we get data from both index 1 and 2
    boutLength = endpos - startpos + 1;

    % put the length in minutes and put it in the correct bucket
    % ((length / 60) / 2) == (length / 120)
    % divide by 2 since each bucket is 2 mins
    bucket = ceil(boutLength / 120);

    % If the bout happens to be larger than 60 minutes it would fall in a
    % bucket that is out of bounds, so take the min of the actual bucket and
    % the last available bucket. This is why the last bucket represents 58+
    % minutes
    bucket = min(bucket, size(boutsPerBucket, 1));
    boutsPerBucket(bucket) = boutsPerBucket(bucket) + 1;
    activityPerBucket(bucket) = activityPerBucket(bucket) + totalActivityCount;
    secondsPerBucket(bucket) = secondsPerBucket(bucket) + boutLength;

    % see formula and example above for activity counts per minute
    activityCountsPerMin(i) = totalActivityCount * 60 / boutLength;

    % find what category bout it is
    %boutCategory = classifyBout(activityCountsPerMin(i));

    % this vector holds the amount of each category of bout we've encountered
    % so far
    %boutsCategorized(boutCategory) = boutsCategorized(boutCategory) + 1;

    % set index corresponding to this bout to the category it was given
    %boutCategories(i) = boutCategory;

    % length of this bout
    boutLengths(i) = boutLength;
end

% get all the bouts for their respective categories
%{

We dont need this right now. This could be used in conjunction with the
boutSetStats local function to gain stats about each category of bouts.

category1Bouts = activeWearTimes(boutCategories == 1, :);
category2Bouts = activeWearTimes(boutCategories == 2, :);
category3Bouts = activeWearTimes(boutCategories == 3, :);
category4Bouts = activeWearTimes(boutCategories == 4, :);
category5Bouts = activeWearTimes(boutCategories == 5, :);
%}

% find activity count per minute per bout statistics
activityCountsPerMinPerBoutAvg = mean(activityCountsPerMin);
activityCountsPerMinPerBoutStd = std(activityCountsPerMin);

% find bout length statistics
boutLengthAvg = mean(boutLengths);
boutLengthStd = std(boutLengths);

% We are guaranteed that the first row in the activeWearTimes is >= to the
% first value in the wear times (once scaled) since we have found only the
% active areas contained within wear times.
startrow = 1;
endrow = 1;

% We can also find the gap sizes while we traverse here. Once we find the start
% and end row for a wear time in the activeWearTimes matrix we can take the
% difference between the end times and start times for the rows
gapSizes = [];
boutsPerWearTime = [];
gapsPerWearTime = [];
wearTimesSize = size(wearTimes);
activityCountsPerWearTime = zeros(size(wearTimes, 1), 1);
for i = 1:size(wearTimes, 1);
    numBouts = 0;
    activityCountForWearTime = 0;

    % multiply by 60 since we found the wear times using a minute scale
    endwear = min(length(axis), wearTimes(i, 2)*60);

    % To search through an entire wear time we start at the beginning of it and
    % go until the end time of the next bout is past the end of the current
    % wear time. When that occurs we go to the next wear time.
    while endrow <= size(activeWearTimes, 1) &&...
          activeWearTimes(endrow, 2) <= endwear
        numBouts = numBouts + 1;
        boutActivity = sum(axis(activeWearTimes(endrow, 1):activeWearTimes(endrow, 2)));
        activityCountForWearTime = activityCountForWearTime + boutActivity;
        endrow = endrow + 1;
    end
    numBouts = endrow - startrow;

    for j = startrow+1:endrow-1
        gapSizes = [gapSizes; activeWearTimes(j, 1) - activeWearTimes(j-1, 2)];
    end

    boutsPerWearTime = [boutsPerWearTime; numBouts];
    gapsPerWearTime = [gapsPerWearTime; numBouts-1];
    activityCountsPerWearTime(i) = activityCountForWearTime;
    startrow = endrow;
end

[bucketForHalfLife, countsPerMinForHalfLife] = halfLife(secondsPerBucket, ...
                                                        activityPerBucket);

% Stats about gap length
gapBetweenBoutsLengthAvg = mean(gapSizes);
gapBetweenBoutsLengthStd = std(gapSizes);

% Stats about bouts per wear time
numBoutsPerWearTimeAvg = mean(boutsPerWearTime);
numBoutsPerWearTimeStd = std(boutsPerWearTime);

% Stats about total activity per wear time
activityCountPerWearTimeAvg = mean(activityCountsPerWearTime);
activityCountPerWearTimeStd = std(activityCountsPerWearTime);

stats = dataset(...
    numWearTimes, ...
    numBoutsTotal, ...
    numBoutsPerWearTimeAvg, ...
    numBoutsPerWearTimeStd, ...
    activityCountsPerMinPerBoutAvg, ...
    activityCountsPerMinPerBoutStd, ...
    boutLengthAvg, ...
    boutLengthStd, ...
    gapBetweenBoutsLengthAvg, ...
    gapBetweenBoutsLengthStd, ...
    activityCountPerWearTimeAvg, ...
    activityCountPerWearTimeStd, ...
    bucketForHalfLife, ...
    countsPerMinForHalfLife, ...
    'VarNames', stats_names ...
);

end % end main statistics function

function boutCategory = classifyBout(boutActivityPerMin)
% CLASSIFYBOUT Depending on the activity count per min label the bout
%   CLASSIFYBOUT Place bouts in one of five categories:
%       Categories:
%       1: 0-99 activity counts per minute
%       2: 100-399 activity counts per minute
%       3: 400-799 activity counts per minute
%       4: 800-999 activity counts per minute
%       5: 1000+ activity counts per minute
%   Inputs:
%       boutActivityPerMin: The activity count per minute of the bout we are
%           going to classify.
%   Output:
%       boutCategory: The category to which the bout belongs.


boutCategory = -1;

if boutActivityPerMin >= 1000
    boutCategory = 5;
elseif boutActivityPerMin >= 800
    boutCategory = 4;
elseif boutActivityPerMin >= 400
    boutCategory = 3;
elseif boutActivityPerMin >= 100
    boutCategory = 2;
else
    boutCategory = 1;
end

end % end classify bout function

function [ boutSetStats ] = findBoutSetStats(bouts, axis)
%FINDBOUTSETSTATS Find all stats about a single category of bouts
%   FINDBOUTSETSTATS This function will be used to find statistics
%   about all category 1 bouts, category 2 bouts, .. etc. In theory it could
%   be used to find stats about any arbitrary set of bouts on the axis.
%
%   Note: When using this for each category the "gapLength" variables may
%   not be of much use, since it could be comparing bouts from separate wear
%   times, resulting in huge gap sizes.
%
%   Input:
%       bouts: An Nx2 matrix where a single row corresponds to a single bout.
%
%       axis: The entire axis of data.
%
%   Output:
%       boutCategoryStats: Stats about the given set of bouts.

numBouts = size(bouts, 1);
activityCountPerMinPerBout = zeros(numBouts, 1);
boutLengths = zeros(numBouts, 1);

boutLengthAvg = 0;
boutLengthStd = 0;

gapLengthAvg = 0;
gapLengthStd = 0;

activityCountsPerMinPerBoutAvg = 0;
activityCountsPerMinPerBoutStd = 0;

% Find the lengths of the bouts and the activity count per min for each bout
for i=1:numBouts
    startpos = bouts(i, 1);
    endpos = bouts(i, 2);

    % bout length
    boutLengths(i) = endpos - startpos;

    % activity count per bout
    totalCount = sum(axis(startpos:endpos));
    activityCountPerMinPerBout(i) = totalCount * 60 / boutLengths(i);
end

% How big are the gaps
gapLengths = zeros(numBouts-1, 1);
for i=2:numBouts
    gapLengths(i-1) = bouts(i, 1) - bouts(i-1, 2);
end

boutLengthAvg = mean(boutLengths);
boutLengthStd = std(boutLengths);

gapLengthAvg = mean(gapLengths);
gapLengthStd = std(gapLengths);

activityCountsPerMinPerBoutAvg = mean(activityCountPerMinPerBout);
activityCountsPerMinPerBoutStd = std(activityCountPerMinPerBout);

boutSetStats = [
    boutLengthAvg ...
    boutLengthStd ...
    gapLengthAvg ...
    gapLengthStd ...
    activityCountsPerMinPerBoutAvg ...
    activityCountsPerMinPerBoutStd ...
];

% replace all NaN values with 0
boutSetStats(isnan(boutSetStats)) = 0;

end % end find bout stats function
