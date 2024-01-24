function derivative = numericDiff (y_val, x_val)
    %{
        function uses numerical method to find the derivitive of funciton not in sy_valmbolic
        using a combo of forward, backward and central difference
        
        Args:
        data (double[]) -> function in numerical form (discrete points given in sequential order)

        Return:
        derivative (double[]) -> the derivative 
    %}
    data_length = numel(x_val);
    derivative = zeros(data_length, 1);

    if (data_length < 3)
        derivative(2) = (y_val(2)-y_val(1))/(x_val(2) - x_val(1));
        return;
    end

    derivative(1) = (y_val(1) - y_val(2))/( x_val(2) - x_val(1) ); %forward difference
    derivative(data_length) = (y_val(data_length) - y_val(data_length-1)) / (x_val(data_length) - x_val(data_length-1)); %backward difference
    derivative(2:data_length-1) =(y_val(1:data_length-2) - y_val(3:data_length))./(x_val(1:data_length-2) - x_val(3:data_length))'; %central difference
end