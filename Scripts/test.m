
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

close all;

%obtain contant values
currentPath = which(mfilename);
constPath = fileparts(fileparts(currentPath))+ "\constant.txt"; %for matlab online, change \constant to /constant
const = txtToDict(constPath);

%define theta and the equations
%To Do: Turn the code below into a function to make it easier to change theta later.
syms t;

[theta, theta_dot, theta_double_dot] = getTheta (sin(t), 0, 0)

%{
theta = sin(t);
theta_dot = diff(theta, t);
theta_double_dot = diff(theta_dot, t);
%}

Tload = const('gear_inertia')*theta_double_dot + const('gear_damping')*theta_dot + const('mass')*const('gravity')*const('pendulum_length')*sin(theta);
Tm = (const('motor_inertia') + const('gear_inertia'))*const('gear_ratio')*theta_double_dot + ((1/const('gear_efficiency'))/const('gear_ratio'))*Tload;
thetam_dot = const('gear_ratio')*theta_dot;
I = (Tm + const('motor_damping')*thetam_dot)/const('k_t');
V = const('motor_inductance')*diff(I, t) + const('motor_resistance')*I + const('k_b')*thetam_dot;

%testing get Tm, thetam_dot, efficiency values
%To Do: Turn the code below into a function, to make it easier to chage t_val and stuff later
t_val = linspace(0, 4*pi, 100);

%I think these might be giving motor efficiency values
test_Tm = double(subs(Tm, t, t_val));
test_thetam_dot = double(subs(thetam_dot, t, t_val));
test_Pelec = double(subs(I, t, t_val)).*double(subs(V, t, t_val));
test_motor_efficiency = (test_Tm.*test_thetam_dot)./test_Pelec;

%I think these give actuator efficiency values
test_Tload = double(subs(Tload, t, t_val));
test_theta_dot = double(subs(thetam_dot, t, t_val));
test_actuator_efficiency = (test_Tload.*test_theta_dot)./test_Pelec;

plotEfficiecny(test_motor_efficiency, t_val, double(subs(theta,t,t_val)), 'motor efficiency')
plotEfficiecny(test_actuator_efficiency, t_val, double(subs(theta,t,t_val)), 'actuator efficiency')

%Looking at difference between motor efficiency and actuator efficiency
figure('windowstyle','docked');
plot (t_val, test_motor_efficiency, 'DisplayName', 'Motor Efficiency', 'color', [0.2 0.5 0.9 0.4], 'LineWidth', 2)
hold on;
plot (t_val, test_actuator_efficiency, 'DisplayName', 'Actuator Efficiency', 'color', 'red', 'LineWidth', 0.5)
hold on;
plot (t_val, abs((test_actuator_efficiency-test_motor_efficiency)./test_motor_efficiency), 'DisplayName', 'Difference', 'color', 'black', 'LineWidth', 1)
hold on;
plot (t_val, double(subs(theta,t,t_val)), '--', 'DisplayName', 'Theta(t)', 'color', 'blue')

legend ('show')
xlabel('Time (s)');
ylabel ('Efficiency / Efficiency Error');
legend ('show');

function plotEfficiecny (efficiency, t_val, theta, name)
    %{
        This is to make a simple efficiency plot of the efficency and the theta angle

        Args:
        efficiency (double[]) -> efficiency values
        t_val (double[]) -> time
        theta (double[]) -> the original joint position
        name (string) -> title of the plot
    %}
    figure('windowstyle','docked');

    plot (t_val, efficiency, 'DisplayName', 'Efficiency', 'color', 'black', 'LineWidth', 1)
    hold on;
    plot (t_val, theta, '--', 'DisplayName', 'Theta(t)', 'color', 'blue')
    hold on;
    plot (t_val, movmean(efficiency, 7), 'DisplayName', 'moving average', 'color', 'r', 'LineWidth', 1.5)
    
    title(name);
    xlabel('Time (s)');
    ylabel ('Efficiency');
    legend ('show');
end







