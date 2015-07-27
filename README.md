#Accelerometer Data Feature Extraction and Classification#
Using accelerometer data gathered from the [Life Study](https://www.thelifestudy.org/public/index.cfm) we model it in a new way by extracting [features](#features). Using the extracted features we perform multiple types of classification to try to identify which method performs best.

##<a id="features"></a>Features List:##
1. **axis1\_proportion** - The magnitude of axis 1 divided by the magnitude of the vector formed by the three axes.
2. **axis2\_proportion** - The magnitude of axis 2 divided by the magnitude of the vector formed by the three axes.
3. **axis3\_proportion** - The magnitude of axis 3 divided by the magnitude of the vector formed by the three axes.
4. **Number\_of\_wear\_times** - The total number of wear times found. This was found using the Choi et. al. wear time algorithm on the vector magnitude axis. This is the same for all axes since it is found using the vector magnitude axis.
5. **axis1\_Total\_number\_of\_bouts** - Total number of bouts across all wear times. The code can be found in identifyActiveAreas.m
6. **axis1\_Number\_of\_bouts\_per\_wear\_time\_avg** - The average number of bouts found in each wear time.
```
avg_num_bouts = total_num_bouts / total_num_weartimes
```
7. **axis1\_Number\_of\_bouts\_per\_wear\_time\_std** - The standard deviation of the number bouts per wear time. Found using the conventional standard deviation formula.
8. **axis1\_Activity\_counts\_per\_minute\_per\_bout\_avg** - The average activity counts per minute (ACPM) per bout in a wear time. This was found by first finding all of the bouts, then finding their ACPM, then finding the average.
9. **axis1\_Activity\_counts\_per\_minute\_per\_bout\_std** - The standard deviation of the ACPM per bout using the standard formula.
10. **axis1\_Bout\_length\_avg** - Average bout length in seconds.
11. **axis1\_Bout\_length\_std** - Standard deviation of the bout lengths.
12. **axis1\_Gap\_between\_bouts\_length\_avg** - The average amount of time (seconds) between bouts. This is the amount of time being inactive between periods of activity.
13. **axis1\_Gap\_between\_bouts\_length\_std** - The standard deviation of the gaps.
14. **axis1\_Activity\_count\_per\_wear\_time\_avg** - The total activity count per wear time. This is not normalized to anything.
15. **axis1\_Activity\_count\_per\_wear\_time\_std** - The standard deviation of the total activity count per wear time.
16. **axis1\_Bucket\_for\_half\_life** - Which bucket does half of the total active time occur at? The lower the bucket number the more activity performed in short intervals. This (hopefully) reveals whether the participant usually performed short activities or longer activities.
17. **axis1\_Counts\_per\_min\_for\_half\_life** - Found by finding the total activity for the bouts that were shorter than or equal to the duration of the discovered half life bucket, then normalizing it based on how many seconds of activity that actually was.
```
halfActivity = sum(activityPerBucket(1:bucket));
countsPerMin = halfActivity * 60 / halfTime;
```

##<a id="weartimes"></a>Wear Times and Bouts:##
Before finding any features it was necessary to identify the times where the device was actually being worn, so only valid data are considered. To accomplish this we used the algorithm developed by [Choi et al][1] based on the vector magnitude (VM) of the three axes. It is a sliding window technique that leverages two windows, a larger window for ensuring a minimum duration of inactivity and a smaller one for upstream and downstream analysis, for increased accuracy. The value chosen for the larger window was 90 minutes and the value for the smaller window was 30 minutes. The upstream and downstream analysis is checking for a level of activity inside the smaller window that exceeds the threshold considered to be inactive (here: two minutes). If a time interval meets both of these criteria then it is considered an interval of nonwear.

Within each wear time we then had to find all the bouts of activity. For a period of activity to be considered a bout it must have an activity count per minute (ACPM) of at least 100. Periods of activity begin with a data point with an activity count above a threshold, and end once thirty consecutive seconds of activity below that threshold are found. The bout is considered to be from the first active second to the last active second before the thirty seconds of inactivity.

[1]: http://www.ncbi.nlm.nih.gov/pubmed/22525772