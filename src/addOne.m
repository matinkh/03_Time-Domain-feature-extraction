function [ features ] = addOne( trainingData, ...
                                trainingLabels, ...
                                validationData, ...
                                validationLabels, ...
                                numFeaturesKept, ...
                                trainerToUse )
%ADDONE Identify the most important features using the add one method.
%   features = ADDONE(trainingData, trainingLabels, validationData, ...
%                     validationLabels, numFeaturesKept)
%
%   features = ADDONE(..., trainerToUse) To specify the trainer to use.
%
%   Inputs:
%       trainingData: The observations that are going to be used for training.
%       This will be an NxM matrix.
%
%       trainingLabels: The category for each observation in the training data.
%       This will be an Nx1 vector.
%
%       validationData: The observations that are going to be used for testing
%       the correctness of the classifier. This will be an KxM matrix.
%
%       validationLabels: The category for each observation in the validation
%       data. This will be an Kx1 vector.
%
%       numFeaturesKept: The number of features in the final set of important
%       features. If this number is greater than the number of features in the
%       trainingData matrix the output will be a vector of all 1's
%
%       trainerToUse: Optional. Default is to use a Classification Tree. The
%       valid inputs are:
%           1 - Classification Tree
%           2 - Classification Discriminant
%           3 - SVM
%
%   Outputs:
%       features: A logical vector of size Mx1 where a zero value at position
%       i indicates that this feature was not considered important, and a value
%       of 1 means that it was determined to be an important feature.
%
%   This begins by considering every feature individually at first. Each
%   feature is then used as the sole classifying feature for the data. The
%   best performing features is then chosen and kept aside.
%   Once the best single feature has been chosen it is paired with every other
%   feature and tried as a classifier. This will result in the best features
%   pair.
%   This process continue until you reach the numer of features specified
%   resulting in the set of best features of size numFeaturesKept.
%
%   Example:
%       A sample run with three data features and we are trying to find the two
%       best.
%
%       Let f1, f2, f3 be all three features of the data. Initially each is run
%       by itself and will result in a percente correctly classified.
%
%       f1: 60%
%       f2: 75%
%       f3: 40%
%
%       Since f2 had the highest percent of correctly classified observations
%       it is chosen and kept aside. Then it is paired up with the remaining
%       features one by one to find the best pair.
%
%       {f2, f1} : 80%
%       {f2, f3} : 70%
%
%       Therefore the best two features are f2 and f1 and the output would be
%       [1; 1; 0].

numTrainers = 3;

% Counter to keep track of how many "important" features we've found.
numFeaturesFound = 0;

% How many features are there total
numFeatures = size(trainingData, 2);

% How many training observations are there
numTrainingObs = size(trainingData, 1);

% How many validation observations are there
numValidationObs = size(validationData, 1);

% How many training labels are there
if isvector(trainingLabels)
    numTrainingLabels = numel(trainingLabels);
else
    error('trainingLabels must be a vector with the same number of rows as trainingData.');
end

% How many validation labels are there
if isvector(validationLabels)
    numValidationLabels = numel(validationLabels);
else
    error('validationLabels must be a vector with the same number of rows as validationData.');
end

% Make sure we have a category for each observation
if numTrainingObs ~= numTrainingLabels
    error('There must be exactly the same number of training labels as training observations.');
elseif numValidationObs ~= numValidationLabels
    error('There must be exactly the same number of validation labels as validation observations.');
elseif numFeaturesKept >= numFeatures
    features = true(numFeatures, 1);
    return;
end

if ~exist('trainerToUse', 'var')
    trainerToUse = 1;
elseif trainerToUse > numTrainers || trainerToUse < 1
    trainerToUse = 1;
end

% The logical vector for keeping track of the important features. It will have
% as many columns as the training data.
features = false(numFeatures, 1);

for i = 1:numFeaturesKept
    fprintf('Finding feature #%d\n', i);

    % The percent correct using this feature as the new feature to include.
    % Features already included will have always have a percent of 0 and
    % therefore will not be reconsidered.
    percentCorrect = zeros(numFeatures, 1);

    for j = 1:numFeatures
        % Do not consider a new set with a feature that is already included
        if features(j)
            continue;
        end

        % train classifier using training data
        % predict validation data using trained classifier
        % find percentage classified correctly and mark it in percentCorrect

        % Train the tree using the already found best set + the new feature.
        newFeatures = features;
        newFeatures(j) = 1;

        %{ ---------- CLASSIFICATION TREE ---------- %}
        if trainerToUse == 1
            tree = ClassificationTree.fit(trainingData(:, newFeatures), ...
                                          trainingLabels);

            predictedLabels = predict(tree, validationData(:, newFeatures));
            clear tree

        %{ ---------- KNN CLASSIFIER ---------- %}
        elseif trainerToUse == 2
            model = ClassificationDiscriminant.fit(trainingData(:, newFeatures), ...
                                                   trainingLabels);

            predictedLabels = predict(model, validationData(:, newFeatures));
            clear model
        %{ ---------- SVM ---------- %}
        elseif trainerToUse == 3
            svms = svmtrain(trainingData(:, newFeatures), ...
                            trainingLabels);
            predictedLabels = svmclassify(svms, ...
                                          validationData(:, newFeatures));
            clear svms
        end

        numRight = sum(predictedLabels == validationLabels);
        percentCorrect(j) = numRight / numValidationObs;
    end

    % find the best feature to add to the set
    [highestCorrect, bestFeatureIndex] = max(percentCorrect);

    fprintf('Adding feature %d with accuracy of %f\n', ...
            bestFeatureIndex, ...
            highestCorrect);

    % keep the new feature
    features(bestFeatureIndex) = 1;
end

end

