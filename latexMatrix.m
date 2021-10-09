function matrices = latexMatrix(input, debug)

% Set default return value
matrices = cell([0, 0]);

% Set default values to arguments user did not specify
if nargin == 1
    debug = false;
end

% Overwrite input with prepared latex string if input = "..."
% For testing purposes
if input == "..."
    input = "\begin{bmatrix} 8 & 7 \\ 6 & 5 \\ 4 & 3 \\ 2 & 1 \end{bmatrix} \cdot \begin{matrix} 1 & 2 & 3\\ 4 & 5 & 6 \end{matrix} \cdot x \cdot \begin{pmatrix} 100 & 3 & 5.05 \\ 2 & 4 & 6 \\ 10 & 15.1 & 16.00001 \end{pmatrix}";
end

% Regex expression for extracting matrices from the latex string
refExp = "((?<=\\begin{\Smatrix})|(?<=\\begin{matrix})).*?(?=\\end{\S?matrix})";

% Current data state:
% raw latex string
% eg: \begin{..} ... \end{...}

% Query matrices from the latex string
temp1 = regexp(input, refExp, "match");
% Remove all whitespaces
temp1 = strrep(temp1, ' ', '');
matrixCount = length(temp1);
% Exit if there is no matrix to be processed
if matrixCount == 0
    return
end

if debug
    disp("latex -> matrices");
    dispCells(temp1);
end

% Current data state:
% array of string matrices
% eg: ["1&2&3\\4&5&6", "...\\...", ...]
% indexing: (i)

% Split matrices into rows
temp2 = cell([matrixCount, 1]);
for i = 1:matrixCount
    temp2{i,1} = split(temp1(i), "\\");
end

if debug
    disp("matrices -> rows");
    dispCells(temp2);
end

% Current data state:
% cell array of arrays of string matrix rows
% eg: [["1&2&3", "4&5&6"], [...], ...]
% indexing: {i, 1}(j)

% Split matrix rows into columns
temp3 = cell([matrixCount, 1]);
for i = 1:matrixCount
    row = temp2{i,1};
    temp3{i,1} = cell([length(row), 1]);
    for j = 1:length(row)
        temp3{i,1}{j,1} = split(row(j), "&");
    end
end

if debug
    disp("rows -> columns");
    dispCells(temp3);
end

% Current data state:
% cell array of cell arrays of arrays of string matrix elements
% eg: [[["1", "2", "3"], ["4", "5", "6"]], [...], ...]
% indexing: {i, 1}{j, 1}(k)

% Convert matrix elements from strings to doubles
% If matrix element is empty string or other nonsense
% => str2double will return NaN
temp4 = cell([matrixCount, 1]);
for i = 1:matrixCount
    row = temp3{i,1};
    temp4{i,1} = cell([length(row), 1]);
    for j = 1:length(row)
        col = row{j,1};
        temp4{i,1}{j,1} = cell([length(col), 1]);
        for k = 1:length(col)
            temp4{i,1}{j,1}{k,1} = str2double(col(k));
        end
    end
end

if debug
    disp("parsing");
    dispCells(temp4);
end

% Current data state:
% cell array of cell arrays of cell arrays of doubles (matrix elements)
% eg: [[[1, 2, 3], [4, 5, 6]], [...], ...]
% indexing: {i, 1}{j, 1}{k, 1}

% Convert cell arrays of matrix elements into actual matrices
% If matrix has uneven number of columns in each row,
% the matrix will dynamically change size to accommodate the longest row
matrices = cell([matrixCount, 1]);
for i = 1:matrixCount
    rowCount = length(temp4{i,1});
    columnCount = length(temp4{i,1}{1,1});
    matrices{i,1} = zeros(rowCount, columnCount);
    for j = 1:rowCount
        currentColumnCount = length(temp4{i,1}{j,1});
        for k = 1:currentColumnCount
            matrices{i,1}(j,k) = temp4{i,1}{j,1}{k,1};
        end
    end
end

if debug
    disp("results");
    dispCells(matrices);
end

% Current data state:
% cell array of matrices
% eg: [[1 2 3 ; 4 5 6], [...], ...]
% indexing: {i, 1}(j,k)

end