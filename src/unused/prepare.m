function [ PCATransformedData ] = prepare( statData, varExp )
%PREPARE Do PCA to achieve the desired variance explained.
%
%   [PCATransformedData] = prepare(statData, varExp)
%
%   Inputs:
%       statData: The matrix where each row is an observation and each
%       column is a feature or variable. This must already have the columns
%       for all irrelevant features removed (e.g. category, axis, etc.). It
%       can have the correlated variables removed already if desired.
%
%       varExp: What percent of the variance must be explained by the PCA.
%       This can be left blank and a default value of 0.9 will be used.
%
%   Outputs:
%       PCATransformedData: The statistics put onto the principal component
%       coordinate system.;

[coeff, ~, explained] = pcacov(corrcoef(statData));

% Find how many principal components we must consider and keep to ensure we
% capture >= some percent of the variance.
cumVarianceExplained = cumsum(explained)./sum(explained);
numPCRequired = 1;

% No explained variance threshold was passed so use default value
if nargin == 1
    varExp = 0.9;
end

for i=1:length(cumVarianceExplained)
    if cumVarianceExplained(i) >= varExp
        break;
    else
        numPCRequired = numPCRequired + 1;
    end
end
%fprintf('%d principal components capture %2.2f%% variance\n',...
%         numPCRequired, cumVarianceExplained(numPCRequired)*100);

% Find the coordinates of the original data in the new coordinate system
% defined by the principal components.
PCATransformedData = statData * coeff(:, 1:numPCRequired);

end
