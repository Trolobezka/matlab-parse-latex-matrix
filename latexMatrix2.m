function matrices = latexMatrix2(input, mode, debug)

% Set default return value
matrices = cell([0, 0]);
    
% Set default values to arguments user did not specify
if nargin == 1
    mode = 1;
    debug = false;
elseif nargin == 2
    debug = false;
end

% Overwrite input with prepared latex string if input = "..."
% For testing purposes
if input == "..."
    input = "\begin{bmatrix} 8 & 7 \\ 6 & 5 \\ 4 & 3 \\ 2 & 1 \end{bmatrix} \cdot \begin{matrix} 1 & 2 & 3\\ 4 & 5 & 6 \end{matrix} \cdot x \cdot \begin{pmatrix} 100 & 3 & 5.05 \\ 2 & 4 & 6 \\ 10 & 15.1 & 16.00001 \end{pmatrix}";
end

% Mode can be:
% 1 = use regex expresion to query matrices out of the latex string
%   Expected input: "\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}"
% 2 = regex is not used, input should be string from the inside of the latex matrix tags
%   Expected input: "1 & 2 \\ 3 & 4"
% 3 = same as 1 + print matrices in matlab syntax (for ctrl+C/V into your script)
%   Printed matrices are created from the final numerical matrices
%   => no support for symbolic variables
% 4 = same as 2 + print matrices in matlab syntax (for ctrl+C/V into your script)
%   Printed matrices are created from the final numerical matrices
%   => no support for symbolic variables
% 5 = same as 1 + print matrices in matlab syntax (for ctrl+C/V into your script)
%   Printed matrices are created from the raw latex string
%   => support for symbolic variables but can contain nonsence if the input is
%   wrongly formatted
% 6 = same as 2 + print matrices in matlab syntax (for ctrl+C/V into your script)
%   Printed matrices are created from the raw latex string
%   => support for symbolic variables but can contain nonsence if the input is
%   wrongly formatted
mode = min(max(mode, 1), 6);

% Turns on/off printing temporary results
% For testing purposes
% debug = true

% Regex expression for extracting matrices from the latex string
refExp = "((?<=\\begin{\Smatrix})|(?<=\\begin{matrix})).*?(?=\\end{\S?matrix})";
    
% Current data state:
% raw latex string
% eg: \begin{..} ... \end{...}

% Check mode and query matrices from the latex string
if mod(mode, 2) == 1
    % mode = 1 or 3 => use regex
    temp1 = regexp(input, refExp, "match");
else
    % mode = 2 or 4 => no regex
    temp1 = [input];
end
% Remove all whitespaces
temp1 = strrep(temp1, ' ', '');
matrixCount = length(temp1);
% Exit if there is no matrix to be processed
if matrixCount == 0
    return
end

if debug
    disp("latex -> matrices")
    dispCells(temp1);
end

% Current data state:
% array of string matrices
% eg: ["1&2&3\\4&5&6", "...\\...", ...]
% indexing: (i)

% Split every matrix into rows
temp2 = cell([matrixCount, 1]);
for i = 1:matrixCount
    temp2{i,1} = split(temp1(i), "\\");
end

if debug
    disp("matrices -> rows")
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
    disp("rows -> columns")
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
    disp("parsing")
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
    disp("results")
    dispCells(matrices);
end

% Current data state:
% cell array of matrices
% eg: [[1 2 3 ; 4 5 6], [...], ...]
% indexing: {i, 1}(j,k)

% If the right mode is selected,
% convert the raw matrices from latex syntax to matlab syntax
if mode == 5 || mode == 6
    matlabCommands = cell([matrixCount, 1]);
    for i = 1:matrixCount
        % Replace '&' with ','
        matlabCommands{i,1} = strrep(temp1(i), '&', ',');
        % Replace '\\' with ';'
        matlabCommands{i,1} = strrep(matlabCommands{i,1}, '\\', ';');
        % Add []
        matlabCommands{i,1} = "[" + matlabCommands{i,1} + "]";
    end
    % Print so the user can copy the matrices
    matlabCommands
% If the right mode is selected, print the processed matrices in matlab syntax
elseif mode == 3 || mode == 4
    matlabCommands = cell([matrixCount, 1]);
    for i = 1:matrixCount
        mSize = size(matrices{i,1});
        matlabCommands{i,1} = "[";
        for j = 1:mSize(1)
            for k = 1:mSize(2)
                matlabCommands{i,1} = matlabCommands{i,1} + num2str(matrices{i,1}(j,k));
                if k ~= mSize(2)
                    matlabCommands{i,1} = matlabCommands{i,1} + ",";
                end
            end
            if j ~= mSize(1)
                matlabCommands{i,1} = matlabCommands{i,1} + ";";
            end
        end
        matlabCommands{i,1} = matlabCommands{i,1} + "]";
    end
    % Print so the user can copy the matrices
    matlabCommands
end

% Custom function for printing nested cell arrays
function dispCells(cells, depth)
    
    % Set default value of depth argument
    if nargin == 1
        depth = 1;
    end
    
    % Generate string shift for nested calls
    shift = "";
    for i = 1:depth
        shift = shift + " ";
    end
    
    s = size(cells);
    for i = 1:s(1)
        for j = 1:s(2)
            % Print current position of the cell
            disp(shift + i + "," + j + ":");
            
            % If the cell contains another cell array
            % => print recursively
            if class(cells{i, j}) == "cell"
                dispCells(cells{i, j}, depth + 1);
            else
                disp(cells{i, j});
            end
        end 
    end
end
end
