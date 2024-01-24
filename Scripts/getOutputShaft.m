function [theta, theta_dot, theta_double_dot, Tload] = getOutputShaft (theta, theta_dot, Tload, const, t_val, benchtopMode)
    %{
        function that it Tloas, theta or theta_dot, then solves for theta, theta_dot and theta double dot
        
        Args:
        theta (symbolic function || 0 || empty || double[]) -> the joint position
        theta_dot (symbolic function || 0 || double[]) -> the joint velocity
        Tload (symbolic function || 0 || double[]) -> the load torque function, in benchtop mode it represents T-drive 
        t_val (double[]) -> range of values to evaluate our double[] over
        benchtop (bool) -> whether the calculation is done for benchtop validation or just for an input function

        Return:
        theta (double[]) -> the joing position
        theta_dot (double[]) -> the joint velocity
        theta_double_dot (double[]) -> the jo`int acceleration
        Tload (double[]) -> get Tload as a symbolic function
    %}

    if benchtopMode == true
        disp ("benchtop mode for output shaft")
        theta = zeros(numel(theta_dot), 1);
        theta_double_dot = zeros(numel(theta_dot), 1);
        Tload = getTload(theta_double_dot, theta_dot, const, Tload);
        return; %this will force it to skip everything else
    end
    
    syms t;
    
    %if theta is a numeric input instead of a symbolic function
    if (numel(theta) > 1)
        disp('theta is numeric input')
        theta_dot = numericDiff(theta, t_val);
        theta_double_dot = numericDiff(theta_dot, t_val);
        Tdriven = const('mass')*const('gravity')*const('pendulum_length').*sin(theta);
        Tload = getTload (theta_double_dot, theta_dot, const, Tdriven);
        return;
    end

    %When theta, theta_dot or x is symbolic
    if (theta ~= 0 && ~isempty(theta))
        disp ("theta is input")
        theta_dot = diff(theta, t);
        
    elseif (theta_dot ~= 0 && ~isempty(theta_dot))
        disp ("theta_dot is indut")
        theta = int(theta_dot, t); %note this won't work depending on how complex the equation is

    else 
        disp ("pass tload")
        disp ("Not set up to solve for theta when given Tload")
    end

    theta_double_dot = diff(theta_dot, t);
    
    %changing from symbolic to numerical
    output_shaft_val = evaluateSymbolic ({theta, theta_dot, theta_double_dot}, t_val);
    theta = output_shaft_val(:, 1);
    theta_dot = output_shaft_val(:, 2);
    theta_double_dot = output_shaft_val(:, 3);
    
    if (Tload == 0)
        Tdriven = const('mass')*const('gravity')*const('pendulum_length').*sin(theta);
        Tload = getTload (theta_double_dot, theta_dot, const, Tdriven);
    end

end

function Tload = getTload (theta_double_dot, theta_dot, const, Tdriven)
    Tload = const('gear_inertia').*theta_double_dot + const('gear_damping').*theta_dot + Tdriven;
end