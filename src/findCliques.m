function [] = findCliques(correlationCoefficients, data, delta)
%GETCLIQUES Find all the cliques between a correlation of .5 and .95
%   Start at .5 and increment by the delta each iteration until the
%   correlation required is above .95
%
%   Input:
%       correlationCoefficients: The sqaure matrix returned by calling
%       corrcoef(M) on the data.
%
%       data: The dataset object to get the feature names from. (If this is
%       not 70 columns wide then you must change the matrix extension on
%       line 50.
%
%       delta: The amount to increase the correlation threshold by each
%       iteration. Must be at least 0.01. If no delta is specified 0.05
%       is used.
%
%   Output:
%       Generates a single file for each correlation threshold with a list
%       of cliques.

if ~exist('data', 'var')
    error('Must give the dataset the correlation is from (trainingData)');
end

if ~exist('delta', 'var')
    delta = 0.05;
end

assert(delta >= 0.01, 'Delta is too small, must be >= 0.01');

corrThreshold = 0.5;

while corrThreshold <= .95
    adjacencyMatrix = correlationCoefficients >= corrThreshold | ...
                      correlationCoefficients <= -corrThreshold;
    
    % Set the diagonal to zeros so we have no self edges
    n = size(adjacencyMatrix, 1);
    adjacencyMatrix(1:n+1:n*n) = 0;
    
    % Get the cliques
    mc = maximalCliques(adjacencyMatrix);
    
    filename = sprintf('../cliques/cliques_%.2f.txt', corrThreshold);
    f = fopen(filename, 'w');
    
    for i = 1:size(mc, 2)
        fprintf(f, '---- CLIQUE %d ----\n', i);
        cliqueMembers = data.Properties.VarNames([false(11, 1); logical(mc(:, i))]);
        fprintf(f, '%s\n', cliqueMembers{:});
    end
    
    fclose(f);
    corrThreshold = corrThreshold + delta;
end

end

