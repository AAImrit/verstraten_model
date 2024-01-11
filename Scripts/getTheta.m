function [theta, theta_dot, theta_double_dot] = getTheta (theta, theta_dot, Tload)
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
    %}

    syms t;

    if (nargin > 1 || theta ~= 0 || ~isempty(theta))
        theta_dot = diff(theta, t);
        theta_double_dot = diff(theta_dot, t);
    elseif (nargin > 1 || theta_dot ~= 0 || ~isempty(theta_dot))
        theta_double_dot = diff(theta, t);
        theta = int(theta_dot, t); %note this won't work depending on how complex the equation is
    
    else 
        disp ("Not set up to solve for theta when given Tload")
    end

end