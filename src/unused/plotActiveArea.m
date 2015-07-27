function plotActiveArea(axis_active_areas, axis_num, triaxial, activeRegion)
%PLOTACTIVEAREA Plot the active area on a figure
%      PLOTACTIVEAREA(axis_active_areas, axis_num, triaxial) Plots the active
%      region from the triaxial matrix as well as the active area +-ERROR,
%      where ERROR is some value that may give us some intuition to see how
%      the active_area compares to the real active region.

if ~exist('activeRegion', 'var')
    fprintf('No specific active region given. Plotting region 1\n');
    activeRegion = 1;
end;

% Should theoretically be the same or slightly larger than one of the
% thresholds defined in identifyActiveAreas
ERROR = 60;

% Display the region start and end
fprintf('Region begins at: %d\n', axis_active_areas(activeRegion,1));
fprintf('Region ends at: %d\n', axis_active_areas(activeRegion,2));

%{ Currently we plot only the first active area for an axis %}
%{ This could easily be refactored to take in a particular region number %}

% Plot the line plus error
f1 = figure; % open a new window
startpos = max(axis_active_areas(activeRegion,1)-ERROR, 1);
endpos = min(axis_active_areas(activeRegion,2)+ERROR, length(triaxial(:,axis_num)));

% Display the region start and end with error
fprintf('Region with error begins at: %d\n', startpos);
fprintf('Region with error ends at: %d\n', endpos);

plot(triaxial(startpos:endpos), 'r');

% Set labels and display properly
xlabel('Seconds');  % X-axis represents seconds
ylabel('Activity Count');    % Y-axis represents the magnitude measured
legend('Active Region +- error'); % Display info
title('Active Region With Error');

% Plot the active region we discovered
f2 = figure; % new window
plot(triaxial(axis_active_areas(activeRegion,1):axis_active_areas(activeRegion,2), axis_num), 'b');

% Set labels and display properly
xlabel('Seconds');  % X-axis represents seconds
ylabel('Activity Count');    % Y-axis represents the magnitude measured
legend('Discovered Active Region');
title('Active Region Discovered');
