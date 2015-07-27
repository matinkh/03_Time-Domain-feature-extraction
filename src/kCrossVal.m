function [ accuracy, cm ] = kCrossVal( data , ...
                                       labels, ...
                                       K, ...
                                       classifier )
%KCROSSVAL Use cross validation to test a classification method.
%   accuracy = KCROSSVAL(data, labels, k, classifier)
%   [accuracy, cm] = KCROSSVAL(...)
%
%   Split the data into K folds and use each one as verification once.
%   The first iteration fold 1 will be kept aside and folds 2:n will be
%   used for training. Then the classifier will be tested against the fold
%   that was held aside. This accuracy will be recorded.
%   Once all folds have been used for validation the total accuracy of the
%   classification is the average accuracy across the runs. Thus, in the
%   end, every observation will have been used for training and testing.
%
%   Inputs:
%       data: The observations to be classified
%
%       labels: The class for each observation. This must be a 1-to-1
%       correspondance with the data. Row i in data must have class
%       labels(i).
%
%       K: The number of subsets ("folds") for the cross validation.
%
%       classifier: Which classification technique to use
%           1. Classification tree
%           2. Classification discriminant
%           3. SVM
%           4. Logistic Regression
%
%   Output:
%       accuracy: The average percent correct from the cross validation.
%
%       cm: The confusion matrix resulting from the trainings. It is the
%       sum of the confusion matrix for each fold.

% Get vector for indexing each fold
indices = zeros(size(data, 1), 1);
for i = 1:K
    indices(i:K:end) = i;
end

% Running total of accuracies which we will divide by the number of folds
% to get the overall accuracy
totalAccuracy = 0.0;

% Store the confusion matrix for the cross validation
cm = zeros(2, 2);

% Run each fold
for i = 1:K
    % The rows to train with. These are the rows outside the current fold.
    trainingIndices = indices ~= i;

    % The rows to validate the classifier with. This is the current fold.
    validationIndices = indices == i;

    % Labels for the training data
    trainingLabels = labels(trainingIndices);

    % The actual training data
    trainingData = data(trainingIndices, :);

    % Labels for the validation data
    validationLabels = labels(validationIndices);

    % The actual validation data
    validationData = data(validationIndices, :);

    switch classifier
        %{ ---------- CLASSIFICATION TREE ---------- %}
        case 1
            tree = ClassificationTree.fit(trainingData, trainingLabels);
            predictedLabels = predict(tree, validationData);
            clear tree
        %{ ---------- CLASSIFICATION DISCRIMINANT ---------- %}
        case 2
            model = ClassificationDiscriminant.fit(trainingData, ...
                                                   trainingLabels);
            predictedLabels = predict(model, validationData);
            clear model
        %{ ---------- SVM ---------- %}
        case 3
            svms = svmtrain(trainingData, trainingLabels);
            predictedLabels = svmclassify(svms, validationData);
            clear svms
        %{ ---------- LOGISTIC REGRESSION  ---------- %}
        case 4
            % Use the logistic regression function I wrote.
            % See "help logistic"
            predictedLabels = logistic(trainingData, ...
                                       trainingLabels, ...
                                       validationData);
        otherwise
            error('Please choose a valid classifier. See help');
    end

    % Percent correct = (# correct / total #)
    numCorrect = sum(predictedLabels == validationLabels);
    totalNum = size(validationLabels, 1);
    runAccuracy = numCorrect / totalNum;

    totalAccuracy = totalAccuracy + runAccuracy;

    predictedZeros = predictedLabels == 0;
    validationZeros = validationLabels == 0;
    % Top left is 0 and 0 (match)
    cm(1, 1) = cm(1, 1) + sum(predictedZeros & validationZeros);
    % Top right is 0 and 1 (mismatch)
    cm(1, 2) = cm(1, 2) + sum(predictedZeros & ~validationZeros);
    % Bottom left is 1 and 0 (mismatch)
    cm(2, 1) = cm(2, 1) + sum(~predictedZeros & validationZeros);
    % Bottom right is 1 and 1 (match)
    cm(2, 2) = cm(2, 2) + sum(~predictedZeros & ~validationZeros);
end

accuracy = totalAccuracy / K;

end
