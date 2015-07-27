function [ uncorrelatedData ] = removeCorrelated( data )
%REMOVECORRELATED Remove all of the highly correlated variables from data
%   We will consider "highly correlated" to be a correlation of an absolute
%   value of 0.8 or greater. The new matrix that is returned will contain
%   no columns that have a correlation coefficient of >= 0.8

R = corrcoef(data);
R_bool = R > 0.8 | R < -0.8;

% Index i will be a zero if it is an independent column, or 1 if it 
dependentColumns = zeros(size(data, 2), 1);

numDependent = 0;
for i=1:size(R_bool, 1)
    for j=1:size(R_bool, 2)
        % j > i will check only the upper triangle of the matrix, not
        % including the diagonal. This is the desired behavior since the
        % matrix is symmetric across the diagonal, and the diagonal is all
        % ones.
        if j > i && R_bool(i, j) == 1
            %fprintf('%d and %d are correlated\n', i, j);
            
            % Only set one to be removed if one of them isn't already.
            % We could make this more sophisticated and try to minimize the
            % number of columns removed, but this is OK for now.
            if dependentColumns(i) ~= 1 && dependentColumns(j) ~= 1
                dependentColumns(i) = 1;
                numDependent = numDependent + 1;
            end
        end
    end
end

%fprintf('There were %d dependent columns removed\n', numDependent);

% The new matrix is all of the rows of the old one, but only the
% independent columns.
uncorrelatedData = data(:, ~dependentColumns);

end

