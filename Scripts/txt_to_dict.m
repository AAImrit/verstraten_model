%some function that read txt file, take each line splits at ":", everything
%before : is the name and after is the value, build a dictionary

x=3

function constant = txt_to_dict(path):
    
    %{
        function reads txt file, takes each line splits in at ":", everything
        before the ":" os the key, and everything after is the value

        Args:
        path (str) -> file path

        Return:
        constant (dict) -> the dictionary with the values
    %}

    %reading data
    fileID = fopen(path, 'r');
    data = fscanf(fileID, '%s');
    fclose(fileID);

    data = split(data, ":");



end