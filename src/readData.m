% Read in the data files and create the variables useful for testing.

validationData = dataset('File', 'baseline1_regular_merged.csv', ...
                         'Delimiter', ',');
trainingData = dataset('File', 'baseline2_regular_merged.csv', ...
                       'Delimiter', ',');

% This selects the single column that is titled 'tot_scr_sppb' and turns it
% into a vector of double values. These are the 1-9 scores.
trainingLabelsSPPB = double(trainingData(:, {'tot_scr_sppb'}));
validationLabelsSPPB = double(validationData(:, {'tot_scr_sppb'}));

% Same as above but for the walk speeds
trainingLabelsWalkSpeed = double(trainingData(:, {'walkspeed'}));
validationLabelsWalkSpeed = double(trainingData(:, {'walkspeed'}));

%{
    ------------------------------------------------------------------
    Get the data for training and validation, excluding all of the metadata
    about the participant
    ------------------------------------------------------------------
%}
% This line will return a cell array where an empty cell means the regex
% did not match and a cell with a 1 in it means it matched
trainingFeatureCheck = regexp(trainingData.Properties.VarNames, ...
                               '(axis1_|axis2_|axis3_|VM_)');
%                              '(axis1_)');
% This finds all the empty cells (i.e. non matching cells)
trainingFeaturesIdx = cellfun(@isempty, trainingFeatureCheck);
% Get the data about those that do match (hence the negation of the isempty
% results
trainingFeatures = trainingData(:, ~trainingFeaturesIdx);
trainingObs = double(trainingFeatures);

validationFeatureCheck = regexp(validationData.Properties.VarNames, ...
                               '(axis1_|axis2_|axis3_|VM_)');
%                               '(axis1_)');
validationFeaturesIdx = cellfun(@isempty, validationFeatureCheck);
validationFeatures = validationData(:, ~validationFeaturesIdx);
validationObs = double(validationFeatures);

% Remove any row that has a NaN in it. If a NaN is left then the
% classification will (almost) definitely throw an error.
trainingToKeep = ~any(isnan(trainingObs), 2);
validationToKeep = ~any(isnan(validationObs), 2);

trainingData = trainingData(trainingToKeep, :);
trainingFeatures = trainingFeatures(trainingToKeep, :);
trainingLabelsSPPB = trainingLabelsSPPB(trainingToKeep);
trainingLabelsWalkSpeed = trainingLabelsWalkSpeed(trainingToKeep);
trainingObs = trainingObs(trainingToKeep, :);
validationData = validationData(validationToKeep, :);
validationFeatures = validationFeatures(validationToKeep, :);
validationLabelsSPPB = validationLabelsSPPB(validationToKeep);
validationLabelsWalkSpeed = validationLabelsWalkSpeed(validationToKeep);
validationObs = validationObs(validationToKeep, :);

clear trainingToKeep validationToKeep

% Break the training data into two sets. One is for training, one is for
% testing. Keep the validation set separate. 60^ for training 40% for
% testing.
numTraining = floor(0.8 * size(trainingLabelsSPPB, 1));
testingObs = trainingObs(numTraining+1:end, :);
testingLabelsSPPB = trainingLabelsSPPB(numTraining+1:end);
testingLabelsWalkSpeed = trainingLabelsWalkSpeed(numTraining+1:end);
trainingObs = trainingObs(1:numTraining, :);
trainingLabelsSPPB = trainingLabelsSPPB(1:numTraining);
trainingLabelsWalkSpeed = trainingLabelsWalkSpeed(1:numTraining);

clear numTraining

addRows = 1;
lf = 5; % low functioning cutoff
if addRows
    % find how many times to add the low row data to make it as close to
    % even as possible, where even means the amount <= 6 is about the
    % amount > 6
    ratio = (sum(trainingLabelsSPPB <= lf) / sum(trainingLabelsSPPB > lf));
    toAdd = floor(1 / ratio);
    
    % get indices of low rows for training data
    lowRowsIndices = trainingLabelsSPPB <= lf;
    
    % get actual rows and labels
    lowRowLabels = trainingLabelsSPPB(lowRowsIndices);
    lowRows = trainingObs(lowRowsIndices, :);
    
    % append the new rows to the data
    trainingLabelsSPPB = [trainingLabelsSPPB; repmat(lowRowLabels, toAdd, 1)];
    trainingObs = [trainingObs; repmat(lowRows, toAdd, 1)];
    trainingData = [trainingData; repmat(trainingData, toAdd, 1)];
    
    % randomly permute the rows so we will get a good distribution of low
    % and high functioning people (since there are now a ton of low
    % functioning people at the end). Do it 3 times to be sure.
    for i = 1:3
        randOrder = randperm(size(trainingLabelsSPPB, 1));
        trainingLabelsSPPB = trainingLabelsSPPB(randOrder);
        trainingObs = trainingObs(randOrder, :);
        trainingData = trainingData(randOrder, :);
    end
    
    clear i ratio toAdd lowRowsIndices lowRowLabels lowRows randOrder;
end
clear addRows lf;

% Set binary labels for the data
trainingLabelsSPPB5 = false(size(trainingLabelsSPPB, 1), 1);
trainingLabelsSPPB5(trainingLabelsSPPB <= 5) = 1;
trainingLabelsSPPB6 = false(size(trainingLabelsSPPB, 1), 1);
trainingLabelsSPPB6(trainingLabelsSPPB <= 6) = 1;
trainingLabelsSPPB7 = false(size(trainingLabelsSPPB, 1), 1);
trainingLabelsSPPB7(trainingLabelsSPPB <= 7) = 1;
trainingLabelsSPPB8 = false(size(trainingLabelsSPPB, 1), 1);
trainingLabelsSPPB8(trainingLabelsSPPB <= 8) = 1;

% Create a set that is <= 5 is one class and >= 9 is another. Do not
% consider in between
SPLIT_LOW = 5;
SPLIT_HIGH = 9;

trainingLabelsWalkSpeedBinary = false(size(trainingLabelsWalkSpeed, 1), 1);
trainingLabelsWalkSpeedBinary(trainingLabelsWalkSpeed < 0.8) = 1;

trainingSPPBSplitIdx = trainingLabelsSPPB <= SPLIT_LOW ...
                       | trainingLabelsSPPB >= SPLIT_HIGH;
trainingDataSplit = trainingData(trainingSPPBSplitIdx, :);
trainingObsSplit = trainingObs(trainingSPPBSplitIdx, :);
trainingLabelsSPPBSplit = trainingLabelsSPPB(trainingSPPBSplitIdx);
trainingLabelsSPPBSplitBinary = false(size(trainingLabelsSPPBSplit, 1), 1);
trainingLabelsSPPBSplitBinary(trainingLabelsSPPBSplit <= SPLIT_LOW) = 1;

testingLabelsSPPB5 = false(size(testingLabelsSPPB, 1), 1);
testingLabelsSPPB5(testingLabelsSPPB <= 5) = 1;
testingLabelsSPPB6 = false(size(testingLabelsSPPB, 1), 1);
testingLabelsSPPB6(testingLabelsSPPB <= 6) = 1;
testingLabelsSPPB7 = false(size(testingLabelsSPPB, 1), 1);
testingLabelsSPPB7(testingLabelsSPPB <= 7) = 1;
testingLabelsSPPB8 = false(size(testingLabelsSPPB, 1), 1);
testingLabelsSPPB8(testingLabelsSPPB <= 8) = 1;

testingLabelsWalkSpeedBinary = false(size(testingLabelsWalkSpeed, 1), 1);
testingLabelsWalkSpeedBinary(testingLabelsWalkSpeed < 0.8) = 1;

testingSPPBSplitIdx = testingLabelsSPPB <= SPLIT_LOW ...
                      | testingLabelsSPPB >= SPLIT_HIGH;
testingObsSplit = testingObs(testingSPPBSplitIdx, :);
testingLabelsSPPBSplit = testingLabelsSPPB(testingSPPBSplitIdx);
testingLabelsSPPBSplitBinary = false(size(testingLabelsSPPBSplit, 1), 1);
testingLabelsSPPBSplitBinary(testingLabelsSPPBSplit <= SPLIT_LOW) = 1;

validationLabelsSPPB5 = false(size(validationLabelsSPPB, 1), 1);
validationLabelsSPPB5(validationLabelsSPPB <= 5) = 1;
validationLabelsSPPB6 = false(size(validationLabelsSPPB, 1), 1);
validationLabelsSPPB6(validationLabelsSPPB <= 6) = 1;
validationLabelsSPPB7 = false(size(validationLabelsSPPB, 1), 1);
validationLabelsSPPB7(validationLabelsSPPB <= 7) = 1;
validationLabelsSPPB8 = false(size(validationLabelsSPPB, 1), 1);
validationLabelsSPPB8(validationLabelsSPPB <= 8) = 1;

validationLabelsWalkSpeedBinary = false(size(validationLabelsWalkSpeed, 1), 1);
validationLabelsWalkSpeedBinary(validationLabelsWalkSpeed < 0.8) = 1;

validationSPPBSplitIdx = validationLabelsSPPB <= SPLIT_LOW ...
                         | validationLabelsSPPB >= SPLIT_HIGH;
validationObsSplit = validationObs(validationSPPBSplitIdx, :);
validationLabelsSPPBSplit = validationLabelsSPPB(validationSPPBSplitIdx);
validationLabelsSPPBSplitBinary = false(size(validationLabelsSPPBSplit, 1), 1);
validationLabelsSPPBSplitBinary(validationLabelsSPPBSplit <= SPLIT_LOW) = 1;

% The 3 way split for the sppb score classification
trainingLabelsSPPBTri = zeros(size(trainingLabelsSPPB, 1), 1);
trainingLabelsSPPBTri(trainingLabelsSPPB <= 6) = 1;
trainingLabelsSPPBTri(trainingLabelsSPPB >=7 & trainingLabelsSPPB <= 8) = 2;

testingLabelsSPPBTri = zeros(size(testingLabelsSPPB, 1), 1);
testingLabelsSPPBTri(testingLabelsSPPB <= 6) = 1;
testingLabelsSPPBTri(testingLabelsSPPB >=7 & testingLabelsSPPB <= 8) = 2;

validationLabelsSPPBTri = zeros(size(validationLabelsSPPB, 1), 1);
validationLabelsSPPBTri(validationLabelsSPPB <= 6) = 1;
validationLabelsSPPBTri(validationLabelsSPPB >=7 & ...
                        validationLabelsSPPB <= 8) = 2;

clear trainingSPPBSplitIdx trainingSPPBSplitVals
clear testingSPPBSplitIdx testingSPPBSplitVals
clear validationSPPBSplitIdx validationSPPBSplitVals
clear trainingFeatureCheck trainingFeaturesIdx
clear validationFeatureCheck validationFeaturesIdx

features;
nTraining = size(trainingLabelsSPPB5, 1);
td6 = trainingData(1:nTraining, featsToKeep6);
td7 = trainingData(1:nTraining, featsToKeep7);
td8 = trainingData(1:nTraining, featsToKeep8);
te6 = trainingData(nTraining+1:end, featsToKeep6);
te7 = trainingData(nTraining+1:end, featsToKeep7);
te8 = trainingData(nTraining+1:end, featsToKeep8);
v6 = validationData(:, featsToKeep6);
v7 = validationData(:, featsToKeep7);
v8 = validationData(:, featsToKeep8);