function [theta, theta_dot, theta_double_dot, Tload] = getOutputShaft (theta, theta_dot, Tload, const)
    %{
        function that it Tloas, theta or theta_dot, then solves for theta, theta_dot and theta double dot
        
        Args:
        theta (symbolic function || 0 || empty) -> the joint position
        theta_dot (symbolic function || 0 || empty) -> the joint velocity
        Tload (symbolic function || 0 || empty) -> the load torque function 

        Return:
        theta (symbolic funvtion) -> the joing position
        theta_dot (sybmbolic function) -> the joint velocity
        theta_double_dot (symbolic function) -> the joint acceleration
        Tload (symbolic function) -> get Tload as a symbolic function
    %}

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

end