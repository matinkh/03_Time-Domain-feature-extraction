function plotActiveWearTimes(wearTimes, activeWearTimes, axisNum, triaxial)
%PLOTACTIVEWEARTIMES Plot the active wear times on a figure
%      PLOTACTIVEWEARTIMES(wearTimes, activeWearTimes, axisNum, triaxial) Plots
%      the wear times on the same figure as the raw data. The raw data will be
%      the blue lines and the red line will be the active wear times.
%      Inputs:
%          wearTimes: The Nx2 matrix of wear time periods
%          activeWearTimes: The Nx2 matrix generated by identifyActiveAreas
%          axisNum: The axis of the triaxial data this is for
%          triaxial: An Nx3 matrix storing the 3 dimensional accelerometer data

INTERVAL = 60;
axis = triaxial(:, axisNum);

% Create the vector of active or nonactive points
activeVector = zeros(length(axis), 1);
for i = 1:length(activeWearTimes)
    height = mean(triaxial(activeWearTimes(i,1):activeWearTimes(i,2), axisNum));
    activeVector(activeWearTimes(i,1):activeWearTimes(i,2)) = height;
end

% Plot the wear time also
%wearTimes = findWearTimes(axis, true);
wearTimesVector = zeros(length(axis), 1);
wearHeight = max(triaxial(:,1)) / 2;
for i = 1:size(wearTimes, 1)
    startpos = min(wearTimes(i,1) * INTERVAL, length(axis));
    endpos = min(wearTimes(i,2) * INTERVAL, length(axis));
    wearTimesVector(startpos:endpos) = wearHeight;
end

f1 = figure; % open a new window
hold on;
plot(axis, '-b');
plot(activeVector, '-r', 'LineWidth', 2);
plot(wearTimesVector, '-c', 'LineWidth', 2);
hold off;

% Set labels and display properly
xlabel('Seconds');  % X-axis represents seconds
ylabel('Activity Count');    % Y-axis represents the magnitude measured

% First line plotted was for raw data, second was to mark the active regions
legend('Raw accelerometer data', 'Active Regions', 'Wear Time Periods');
title(sprintf('%s %d', 'Active Regions in Wear Times for Axis ', axisNum));
