%obtain contant values
currentPath = which(mfilename);
constPath = fileparts(fileparts(currentPath))+ "\const.txt";
const = txtToDict(constPath);


%simplest implementation we know theta(t), and we let theta(t) = sin(t)
%{
    things to try:
    - let theta(t) = sin(t)
    - let thetam_dot = [vector]
    - let thetamD_dot = ct
    - let Tm = [vector]
    - let Tload = some function, and solve for theta 
%}

%define theta
syms t;

theta = sin(t);
theta_dot = diff(theta, t);
theta_double_dot = diff(theta_dot, t);

Tload = const('gear_inertia')*theta_double_dot + const('gear_damping')*theta_dot + const('mass')*const('gravity')*const('pendulum_length')*sin(theta);
Tm = (const('motor_inertia') + const('gear_interia'))*const('gear_ratio')*theta_double_dot + ((1/const('gear_efficiency'))/const('gear_ratio'))*Tload;

t_val = linspace(0, 4*pi, 100);
test_val = subs(Tm, t, t_val)


%{
    issues with simples case:
    - can't really make a heatmap out of this, will only get specific thetam_dot, Tm values
    - remeber for heatmap, motor velocity is independent variable, motor torque is non independent
%}



