function [ correlation, sums ] = axisCorrelation( triaxial,  wearTimes )
%AXISCORRELATION Find the correlation in magnitudes between bouts on the
%different axes
%   AXISCORRELATION(triaxial, wearTimes)
%   Find the average ratio between bout magnitudes across all
%   three axes. It will find the magnitude ratio between
%       Axis1 <--> Axis2   [axis1/axis2
%       Axis2 <--> Axis3    axis2/axis3
%       Axis1 <--> Axis3    axis1/axis3]
%   and return the them as a vector in that order.
%
%   [correlation, sums] = AXISCORRELATION(...)
%   Also returns the sums of activity counts for each axis. They are returned
%   in numerical order.
%       [axis1 sum
%        axis2 sum
%        axis3 sum];
%
%   The magnitude will be found by summing all the bouts found (which will be
%   identical across the three axes) for each axes, then dividing the lower
%   numbered axes by the higher numbered axes.

activeBouts = findBoutsVM(triaxial, wearTimes);

axis1 = triaxial(:, 1);
axis2 = triaxial(:, 2);
axis3 = triaxial(:, 3);

axis1Bouts = 0;
axis2Bouts = 0;
axis3Bouts = 0;

for i = 1:size(activeBouts, 1)
    startpos = activeBouts(i, 1);
    endpos = activeBouts(i, 2);

    axis1Bouts = axis1Bouts + sum(axis1(startpos:endpos));
    axis2Bouts = axis2Bouts + sum(axis2(startpos:endpos));
    axis3Bouts = axis3Bouts + sum(axis3(startpos:endpos));
end

correlation = [
    axis1Bouts / axis2Bouts;
    axis2Bouts / axis3Bouts;
    axis1Bouts / axis3Bouts;
];

sums = [
    axis1Bouts
    axis2Bouts
    axis3Bouts
];

end

function [ bouts ] = findBoutsVM( triaxial, wearTimes )
%FINDBOUTSVM Using the vector magnitude axis find the active bouts.
%   FINDBOUTSVM Using the vector magnitude axis find the active bout times.

triaxis_squared = triaxial .* triaxial;
axis = sqrt(sum(triaxis_squared, 2));

bouts = [];

for i = 1:size(wearTimes, 1)
    bouts = [bouts; identifyActiveAreas(axis)];
end

%plotVMAxis(axis, bouts, wearTimes);

end

