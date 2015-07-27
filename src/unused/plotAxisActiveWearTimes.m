function plotAxisActiveWearTimes(triaxial, axisNum)
%PLOTAXISACTIVEWEARTIMES Plot the active wear times on a figure
%      PLOTAXISACTIVEWEARTIMES(triaxial, axisNum)
%      Inputs:
%          triaxial: An Nx3 matrix storing the 3 dimensional accelerometer data
%          axisNum: The axis you want to plot

if axisNum > 3 || axisNum < 0
    fprintf('Axis must be 1, 2, or 3');
    return
end

axis = triaxial(:, axisNum);
wearTimes = findWearTimes(axis, true, true);
activeWearTimes = [];
INTERVAL = 60;

% Only find the active areas that are within our found wear times
wearTimesSize = size(wearTimes);
for i = 1:wearTimesSize(1, 1);
    startpos = min(wearTimes(i,1) * INTERVAL, length(axis));
    endpos = min(wearTimes(i,2) * INTERVAL, length(axis));

    % add startpos to them otherwise they all come out in a small range since
    % the identifyActiveAreas would view them all as starting at 1.
    activeWearTimes = [activeWearTimes;
                       (identifyActiveAreas(axis(startpos:endpos))+startpos)];
end

plotActiveWearTimes(wearTimes, activeWearTimes, axisNum, triaxial);
stats = findStatistics(wearTimes, activeWearTimes, axis, true, 0);
