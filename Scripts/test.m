
%simplest implementation we know theta(t), and we let theta(t) = sin(t
%{
    issues with simples case:
    - can't really make a heatmap out of this, will only get specific thetam_dot, Tm values
    - remeber for heatmap, motor velocity is independent variable, motor torque is non independent

    things to try:
    - let theta(t) = sin(t)
    - let thetam_dot = [vector]
    - let thetamD_dot = ct
    - let Tm = [vector]
    - let Tload = some function, and solve for theta 
%}

%obtain contant values
currentPath = which(mfilename);
constPath = fileparts(fileparts(currentPath))+ "\constant.txt";
const = txtToDict(constPath);

%define theta and the equations
syms t;

theta = sin(t);
theta_dot = diff(theta, t);
theta_double_dot = diff(theta_dot, t);

Tload = const('gear_inertia')*theta_double_dot + const('gear_damping')*theta_dot + const('mass')*const('gravity')*const('pendulum_length')*sin(theta);
Tm = (const('motor_inertia') + const('gear_inertia'))*const('gear_ratio')*theta_double_dot + ((1/const('gear_efficiency'))/const('gear_ratio'))*Tload;
thetam_dot = const('gear_ratio')*theta_dot;
I = (Tm + const('motor_damping')*thetam_dot)/const('k_t');
V = const('motor_inductance')*diff(I, t) + const('motor_resistance')*I + const('k_b')*thetam_dot;

%testing get Tm, thetam_dot, efficiency values
t_val = linspace(0, 4*pi, 100);
test_Tm = double(subs(Tm, t, t_val));
test_thetam_dot = double(subs(thetam_dot, t, t_val));
test_Pelec = double(subs(I, t, t_val)).*double(subs(V, t, t_val));
test_efficiency = (test_Tm.*test_thetam_dot)./test_Pelec;

%simple plot
figure(1)
plot (t_val, test_efficiency)
hold on;
plot (t_val, sin(t_val))





