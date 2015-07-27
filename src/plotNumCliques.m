function [] = plotNumCliques( corrCoefficients, delta )
%PLOTNUMCLIQUES Plot a bargraph of the number of cliques per threshold
%   Threshold starts at .5 and goes to .95

if ~exist('delta', 'var')
    delta = 0.05;
end

assert(delta >= 0.01, 'Delta is too small, must be >= 0.01');

corrThreshold = 0.5;
corrs = [];

while corrThreshold <= .95
    adjacencyMatrix = corrCoefficients >= corrThreshold | ...
                      corrCoefficients <= -corrThreshold;
    
    % Set the diagonal to zeros so we have no self edges
    n = size(adjacencyMatrix, 1);
    adjacencyMatrix(1:n+1:n*n) = 0;
    
    % Get the cliques
    mc = maximalCliques(adjacencyMatrix);
    numCliques = size(mc, 2);
    corrs = [corrs; corrThreshold, numCliques];
    corrThreshold = corrThreshold + delta;
end

plot(corrs(:, 1), corrs(:, 2));
title('Number of cliques for a given threshold');
xlabel('Correlation threshold');
ylabel('Number of cliques');

end

