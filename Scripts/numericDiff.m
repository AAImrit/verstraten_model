function derivative = numericDiff (y_val, x_val)
    %{
        function uses numerical method to find the derivitive of funciton not in symbolic
        using a combo of forward, backward and central difference
        
        Args:
        data (double[]) -> function in numerical form (discrete points given in sequential order)

        Return:
        derivative (double[]) -> the derivative 
    %}
    data_length = numel(x);
    derivative = zeros(data_length);

    if (data_length < 3)
        derivative(2) = (y(2)-y(1))/(x(2) - x(1));
        return;
    end

    derivative(1) = (y(1) - y(2))/( x(2) - x(1) ); %forward difference
    derivative(data_length) = (y(data_length) - y(data_length-1)) / (x(data_length) - x(data_length-1)); %backward difference
    derivative(2:data_length-1) = (y(1:data_length-2) - y(3:data_length))./(x(1:data_length-2) - x(3:data_length)); %central difference
end