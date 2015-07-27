function plotActivityAgainstSteps(filename)
%PLOTACTIVITYAGAINSTSTEPS Plot the activity and steps
%       PLOTACTIVITYAGAINSTSTEPS(m) plots the activity measurements on the
%       same figure as the step measurements. 'm' is assumed to be from the
%       CSV files in the "Pattern recognition data" folder with the header
%       information removed.

% Start reading at row 11 and column 2 so we get rid of the header info as
% well as the extraneous data
file_data = csvread(filename, 11, 2);
figure;                 % open a new window
plot(file_data(:,1));   % plot the activity measurement
hold on;                % hold on the figure so we can plot the steps also
plot(file_data(:,2)*25, '.r');  % plot the steps scaled up by x25

% Appropriate labels and identifiers
xlabel('Seconds');      % X-axis represents seconds
ylabel('Magnitude');    % Y-axis represents the magnitude measured
legend('Activity', 'Steps*25'); % Display the helpful info
title('Plot of activity and steps'); % Useful title

% find some statistics out
%{ 
    If this is an Nx2 matrix these print statements will all execute twice,
    once for each column.
%}
%{
fprintf('Mean of the data: %f\n', mean(file_data));
fprintf('Standard deviation of the data: %f\n', std(file_data));
fprintf('Covariance of the activity count: %f\n', mean(file_data(:,1))/std(file_data(:,1)));
fprintf('Covariance of the steps: %f\n', mean(file_data(:,2))/std(file_data(:,2)));
%}


%{ This method shows the results in a matrix appearance %}
disp('Mean of the data:');
disp(mean(file_data));
disp('Standard deviation of the data');
disp(std(file_data));
disp('Covariance of the activity');
disp(mean(file_data(:,1))/std(file_data(:,1)));
disp('Covariance of the steps');
disp(mean(file_data(:,2))/std(file_data(:,2)));
