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