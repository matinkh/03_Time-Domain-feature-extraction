function plotTriAxialData(m)
%PLOTTRIAXIALDATA Plot the activity of the three axes
%       PLOTACTIVITYAGAINSTSTEPS(m) plots the activity measurements on the
%       same figure as the step measurements. 'm' is assumed to be from the
%       CSV files in the "LIFE example home data" folder with the header
%       information removed.

%{
% Start reading at row 11 and column 2 so we get rid of the header info as
% well as the extraneous data
%file_data = csvread('../LIFE example home data/ADAEA5182204F06.csv',10,0);
file_data = csvread(filename,10,0);
%}
file_data = m;                 % since we pass the matrix now

% Create the first figure using axis 1 data
f1 = figure('Name', 'Vertical Axis Data');
plot(file_data(:,1), 'xblue'); % plot the activity measurement
xlabel('Seconds');             % X-axis represents seconds
ylabel('Activity Count');      % Y-axis represents the magnitude measured
title('Vertical Axis');
saveas(f1, '_X_axis.png');

% Figure 2 using axis 2
f2 = figure('Name', 'Horizontal Axis Data');
plot(file_data(:,2), 'hexagramred');  % plot the second axis
xlabel('Seconds');             % X-axis represents seconds
ylabel('Activity Count');      % Y-axis represents the magnitude measured
title('Horizontal Axis');
saveas(f2, '_Y_axis.png');

% Figure 3 using axis 3
f3 = figure('Name', 'Perpendicular Axis Data');
plot(file_data(:,3), '.cyan'); % plot the third axis
xlabel('Seconds');             % X-axis represents seconds
ylabel('Activity Count');      % Y-axis represents the magnitude measured
title('Perpendicular Axis');
saveas(f3, '_Z_axis.png');
