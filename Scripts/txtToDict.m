%some function that read txt file, take each line splits at ":", everything
%before : is the name and after is the value, build a dictionary

function constant = txtToDict(path)
    
    %{
        function reads txt file, takes each line splits in at ":", everything
        before the ":" os the key, and everything after is the value

        Args:
        path (str) -> file path

        Return:
        constant (dict) -> the dictionary with the values
    %}

    fileID = fopen(path, 'r');
    constant = containers.Map;

    % Read lines until the end of the file
    while ~feof(fileID)
        currentLine = fgetl(fileID); % Read the current line

        % Check if the line is not empty
        if ischar(currentLine)
            parts = strsplit(currentLine, ':');
            
            % Extract key and value
            key = strtrim(parts{1}); % Remove leading/trailing spaces
            value = str2double(strtrim(parts{2})); % Convert value to double
            constant(key) = value; % Add the key-value pair to the dict
        end
    end
end