function activeAreasWithoutGap = identifyActiveAreasWithoutGaps(axis)
%IDENTIFYACTIVEAREAS Find all active regions of a single axis without small gaps
%      IDENTIFYACTIVEAREAS(axis) Given a vector representing a single axis from
%      the accelerometer data it will identify the active regions using the
%      identifyActiveAreas function and find the small gap threshold using
%      getGapThreshold. Then remove all the gaps that are smaller than that.

    INTERVAL = 60; % 1 minute
    wearTimes = findWearTimeIntervals(axis);
    activeAreasWithoutGap = [];

    % Go through all the wear times. Find the active windows that are within the
    % current wear time range by passing the axis(startwear:endwear) to the
    % identifyActiveAreas function.
    for i = 1:length(wearTimes)
        fprintf('Examining wear time #%d...\n', i);
        startwear = wearTimes(i, 1)*INTERVAL;
        endwear = min(wearTimes(i, 2)*INTERVAL, length(axis));
        fprintf('startwear = %d\tendwear = %d\n', startwear, endwear);
        activeWindows = identifyActiveAreas(axis(startwear:endwear));
        activeWindows = activeWindows + startwear;

        if length(activeWindows) <= 3
            fprintf('Not enough active windows to warrant collapsing gaps, %d\n', length(activeWindows));
            % add all the active windows
            for j = 1:length(activeWindows)
                fprintf('j = %d ', j);
                activeAreasWithoutGap = [activeAreasWithoutGap;
                                         activeWindows(j,:)];
            end
            fprintf('\n');
        else
            threshold = getGapThreshold(activeWindows);

            gapBeginnings = activeWindows(1:length(activeWindows)-1, 2);
            gapEndings = activeWindows(2:length(activeWindows), 1);
            gapSizes = gapEndings - gapBeginnings;

            fprintf('Collapsing the gaps below the found threshold of %d... ',...
                                                                     threshold);

            newRows = collapseGaps(gapSizes, activeWindows, threshold);
            activeAreasWithoutGap = [activeAreasWithoutGap; newRows];
            %for j = 1:length(activeWindows)
                %activeAreasWithoutGap = [activeAreasWithoutGap;
                                         %activeWindows(j,:)];
            %end
            fprintf('Done.\n');
        end
    end

end % End function

function activeAreasWithoutGap = ...
                    collapseGaps(gapSizes, activeWindows, threshold)
%COLLAPSEGAPS Helper function to collapse the active areas within wear times

    % gapSizes(1) corresponds to rows 1 and 2 of activeWindows.
    % Therefore if gapSizes(1) < threshold we must remove the gap. We do this by
    % concatinating rows 1 and 2 together, for example if the threshold was 5
    % [...; 4 9; 12 20; ...] would become [...; 4 20; ...]
    % Be careful if there is more than 1 small gap in a row though.

    activeAreasWithoutGap = [];
    i = 1;
    gapsRemoved = 0;
    while i <= length(gapSizes)
        if gapSizes(i) < threshold
            startpos = i;

            gapsRemoved = gapsRemoved + 1;
            while i < length(gapSizes) && gapSizes(i) < threshold
                i = i + 1;
                gapsRemoved = gapsRemoved + 1;
            end

            if i == length(gapSizes) && gapSizes(length(gapSizes)) < threshold
                activeAreasWithoutGap = [activeAreasWithoutGap;...
                            activeWindows(startpos, 1) activeWindows(i+1, 2)];
            else
                activeAreasWithoutGap = [activeAreasWithoutGap;...
                            activeWindows(startpos, 1) activeWindows(i, 2)];
            end
        else
            if i == length(gapSizes) && activeWindows(i+1, 1)...
                                      - activeWindows(i, 2) > threshold

                activeAreasWithoutGap = [activeAreasWithoutGap;...
                                         activeWindows(i, :)];

                activeAreasWithoutGap = [activeAreasWithoutGap;...
                                         activeWindows(i+1, :)];

            elseif i == length(gapSizes) && activeWindows(i+1, 1)...
                                          - activeWindows(i, 2) < threshold

                activeAreasWithoutGap = [activeAreasWithoutGap;...
                            activeWindows(i, 1) activeWindows(i+1, 2)];

            else
                activeAreasWithoutGap = [activeAreasWithoutGap;...
                                         activeWindows(i, :)];
            end
        end

        i = i + 1;
    end

    fprintf('Removed %d gaps... ', gapsRemoved);
end % End function
