function plotAllAxesActiveWear( triaxial )
%PLOTALLAXESACTIVEWEAR Create 3 figures, 1 for each axis, plotting active wear.
%   Three figures will be created, each one representing a single axis from
%   the triaxial data.

INTERVAL = 60;

axis1 = triaxial(:, 1);
axis2 = triaxial(:, 2);
axis3 = triaxial(:, 3);

% Get the wear times using the vector magnitude approach. This means the
% wear times will be the same for all 3 axes.
wearTimes = allAxisWearTimes(triaxial, true, true);

% Find all the active areas for axis 1
axis1ActiveWearTimes = [];
for i = 1:size(wearTimes, 1);
    startpos = min(wearTimes(i,1) * INTERVAL, length(axis1));
    endpos = min(wearTimes(i,2) * INTERVAL, length(axis1));

    % add startpos to them otherwise they all come out in a small range since
    % the identifyActiveAreas would view them all as starting at 1.
    activeRegions = identifyActiveAreas(axis1(startpos:endpos))+startpos;
    axis1ActiveWearTimes = [axis1ActiveWearTimes; activeRegions];
end

% Find all the active areas for axis 2
axis2ActiveWearTimes = [];
for i = 1:size(wearTimes, 1);
    startpos = min(wearTimes(i,1) * INTERVAL, length(axis2));
    endpos = min(wearTimes(i,2) * INTERVAL, length(axis2));

    % add startpos to them otherwise they all come out in a small range since
    % the identifyActiveAreas would view them all as starting at 1.
    axis2ActiveWearTimes = [axis2ActiveWearTimes; 
                    (identifyActiveAreas(axis2(startpos:endpos))+startpos)];
end

% Find all the active areas for axis 3
axis3ActiveWearTimes = [];
for i = 1:size(wearTimes, 1);
    startpos = min(wearTimes(i,1) * INTERVAL, length(axis3));
    endpos = min(wearTimes(i,2) * INTERVAL, length(axis3));

    % add startpos to them otherwise they all come out in a small range since
    % the identifyActiveAreas would view them all as starting at 1.
    axis3ActiveWearTimes = [axis3ActiveWearTimes; 
                    (identifyActiveAreas(axis3(startpos:endpos))+startpos)];
end

% Plot them all on separate figures
plotActiveWearTimes(wearTimes, axis1ActiveWearTimes, 1, triaxial);
plotActiveWearTimes(wearTimes, axis2ActiveWearTimes, 2, triaxial);
plotActiveWearTimes(wearTimes, axis3ActiveWearTimes, 3, triaxial);

end

