function [ accuracy, cm ] = testClassifier ( trainingData, trainingLabels, ...
                                             testingData, testingLabels, ...
                                             classifier )
%TESTCLASSIFIER Use a classifier on the test data.
%   accuracy = TESTCLASSIFIER(trainingData, trainingLabels, testingData,
%   testingLabels, classifier)
%   [accuracy, cm] = TESTCLASSIFIER(...)
%
%   Train the classifier on the training data and then test it on the
%   testing data.
%
%   Input:
%       data: The test data observations
%
%       labels: The class for each of the observations. There must be a
%       one-to-one correlation with the rows in the data matrix.
%
%       classifier:
%           1. Classification Tree
%           2. Classification Discriminant
%           3. SVM
%           4. Logistic Regression
%
%   Output:
%       accuracy: The percent of the observations that were correctly
%       guessed.
%
%       cm: Confusion matrix for the tested classifier

switch classifier
    %{ ---------- CLASSIFICATION TREE ---------- %}
    case 1
        tree = ClassificationTree.fit(trainingData, trainingLabels);
        predictedLabels = predict(tree, testingData);
        clear tree
    %{ ---------- CLASSIFICATION DISCRIMINANT ---------- %}
    case 2
        model = ClassificationDiscriminant.fit(trainingData, ...
                                               trainingLabels);
        predictedLabels = predict(model, testingData);
        clear model
    %{ ---------- SVM ---------- %}
    case 3
        svms = svmtrain(trainingData, trainingLabels);
        predictedLabels = svmclassify(svms, testingData);
        clear svms
    %{ ---------- LOGISTIC REGRESSION  ---------- %}
    case 4
        % Use the logistic regression function I wrote.
        % See "help logistic"
        predictedLabels = logistic(trainingData, ...
                                   trainingLabels, ...
                                   testingData);
    otherwise
        error('Please choose a valid classifier. See help');
end

% Percent correct = (# correct / total #)
numCorrect = sum(predictedLabels == testingLabels);
totalNum = size(testingLabels, 1);
accuracy = numCorrect / totalNum;

cm = zeros(2, 2);
predictedZeros = predictedLabels == 0;
testingZeros = testingLabels == 0;

% Top left is 0 and 0 (match)
cm(1, 1) = sum(predictedZeros & testingZeros);
% Top right is 0 and 1 (mismatch)
cm(1, 2) = sum(predictedZeros & ~testingZeros);
% Bottom left is 1 and 0 (mismatch)
cm(2, 1) = sum(~predictedZeros & testingZeros);
% Bottom right is 1 and 1 (match)
cm(2, 2) = sum(~predictedZeros & ~testingZeros);

end % switch classifier

