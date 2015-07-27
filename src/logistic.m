function [ classified, probabilities ] = logistic( trainingObs, ...
                                                   trainingLabels, ...
                                                   testingObs )
%LOGISTIC Use logistic regression to classify the testing observations.
%   classified = LOGISTIC(trainingObs, trainingLabels, testingObs)
%   [classified, probabilities] = LOGISTIC(...)
%
%   Input:
%       trainingObs: Observations that will be used to learn the regression
%
%       trainingLabels: Labels of the observations. Must be a 1-to-1
%       relationship with the observations. trainingObs(i, :) must have a
%       class label of trainingLabels(i)
%
%       testingObs: Values to compute the predictions for
%
%   Output:
%       classified: The binary labels of 0 or 1 corresponding to the
%       prediction
%
%       probabilities: The actual probabilities obtained for each
%       observation

% Fit to our data
b = glmfit(trainingObs, trainingLabels, 'binomial', 'link', 'logit');

% Get estimates based on the fitting
probabilities = glmval(b, testingObs, 'logit');

% Clamp those into 0's and 1's
classified = false(size(testingObs, 1), 1);
classified(probabilities > 0.5) = 1;

end