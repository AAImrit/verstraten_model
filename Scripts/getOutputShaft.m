function [theta, theta_dot, theta_double_dot, Tload] = getOutputShaft (theta, theta_dot, Tload, const, t_val, benchtopMode)
    %{
        function that it Tloas, theta or theta_dot, then solves for theta, theta_dot and theta double dot
        
        Args:
        theta (symbolic function || 0 || empty) -> the joint position
        theta_dot (symbolic function || 0 || double[]) -> the joint velocity
        Tload (symbolic function || 0 || double[]) -> the load torque function, in benchtop mode it represents T-drive 
        t_val (double[]) -> range of values to evaluate our double[] over
        benchtop (bool) -> whether the calculation is done for benchtop validation or just for an input function

        Return:
        theta (double[]) -> the joing position
        theta_dot (double[]) -> the joint velocity
        theta_double_dot (double[]) -> the joint acceleration
        Tload (double[]) -> get Tload as a symbolic function
    %}

    if benchtopMode == true
        theta = zeros(numel(theta_dot), 1);
        theta_double_dot = zeros(numel(theta_dot), 1);
        Tload = const('gear_inertia').*theta_double_dot + const('gear_damping').*theta_dot + Tload;
        return; %this will force it to skip everything else
    end

    syms t;
    
    if (theta ~= 0 && ~isempty(theta))
        theta_dot = diff(theta, t);
        
    elseif (theta_dot ~= 0 && ~isempty(theta_dot))
        theta = int(theta_dot, t); %note this won't work depending on how complex the equation is

    else 
        disp ("pass tload")
        disp ("Not set up to solve for theta when given Tload")
    end

    theta_double_dot = diff(theta_dot, t);
    if (Tload == 0)
        Tload = const('gear_inertia')*theta_double_dot + const('gear_damping')*theta_dot + const('mass')*const('gravity')*const('pendulum_length')*sin(theta);
    end
    
    %bad practice but I gave up
    %evaluating the function for the range of t_val
    result = evaluateSymbolic ({theta, theta_dot, theta_double_dot, Tload}, t_val);
    theta = result(:, 1);
    theta_dot = result(:, 2);
    theta_double_dot = result(:, 3);
    Tload = result(:, 4);

end