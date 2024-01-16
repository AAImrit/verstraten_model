
function result = evaluateSymbolic (equations, val)
    %{
        take symbolic equationd and turn evalute over a specific range

        Args:
        equations (list) -> a list containing symbolic equations
        val (double[]) -> a vector containing values over which we want to evaluate our symbolic function

        Returns:
        reulst (list) -> 2D array, where each column is 1 euqations values over the range defined in val
    %}
    syms t;
    result = zeros(numel(val), numel(equations));

    for i = 1:numel(equations)
        result(:,i) = double(subs(equations{i}, t, val));
    end
end