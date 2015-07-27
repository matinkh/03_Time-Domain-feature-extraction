function [ bucket, countsPerMin ] = halfLife( secondsPerBucket, ...
                                              activityPerBucket )
%HALFLIFE Find the bucket for half life.
%   bucket = HALFLIFE(secondsPerBucket). This can be used to find the half life
%   for active times or inactive times.
%
%   [bucket, countsPerMin] = halfLife(..., activityPerBucket). Will also find
%   the counts/min for the time up to the half life. This is only useful for
%   active bout analysis.
%
%   Input:
%       secondsPerBucket: The total number of seconds for each bucket found by
%       summing the durations for every bout of that length. Therefore bucket
%       one would be sum(all bouts <= duration for bucket 1). Bucket two would
%       be sum(all bout > duration for bucket 1 and <= bucket 2).
%
%       activityPerBucket: The total activity for each bucket found in the same
%       manner as the seconds per bucket.
%
%   Output:
%       bucket: The bucket which has a cumulative sum of half of the total
%       seconds of activity.
%
%       countsPerMin: The activity counts per minute found by treating the
%       buckets from 1:bucket as a single bucket and finding the ACPM
%
%   The use in finding the bucket that marks where half the total time has
%   occured is that it tells you if there are mostly short bouts or mostly
%   longer bouts. If the bucket for the half life is near the beginning then
%   there are mostly short bouts for this person. If it is near the middle or
%   end then they are longer.

% Total time active or sedentary
totalTime = sum(secondsPerBucket);
halfTime = 0;
bucket = 0;

while halfTime < (totalTime / 2)
    bucket = bucket + 1;
    halfTime = halfTime + secondsPerBucket(bucket);
end

if nargin == 2
    halfActivity = sum(activityPerBucket(1:bucket));
    countsPerMin = halfActivity * 60 / halfTime;
end
