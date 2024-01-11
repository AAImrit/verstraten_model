
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
clear all;
clc;

%obtain contant values
currentPath = which(mfilename);
constPath = fileparts(fileparts(currentPath))+ "\constant.txt"; %for matlab online, change \constant to /constant
const = txtToDict(constPath);

%define theta and the equations
%To Do: Turn the code below into a function to make it easier to change theta later.
syms t;

[theta, theta_dot, theta_double_dot, Tload] = getOutputShaft (sin(t), 0, 0, const);

%**NOTE:these will probably to be calculated not-symbolically to actually
%accout for motor operation quadrant
Tm = (const('motor_inertia') + const('gear_inertia'))*const('gear_ratio')*theta_double_dot + ((1/const('gear_efficiency'))/const('gear_ratio'))*Tload;
thetam_dot = const('gear_ratio')*theta_dot;
I = (Tm + const('motor_damping')*thetam_dot)/const('k_t');
V = const('motor_inductance')*diff(I, t) + const('motor_resistance')*I + const('k_b')*thetam_dot;

%testing get Tm, thetam_dot, efficiency values
%To Do: Turn the code below into a function, to make it easier to chage t_val and stuff later
t_val = linspace(0, 4*pi, 100);

%I think these might be giving motor efficiency values
test_val = evaluateSymbolic({Tm, thetam_dot, I, V}, t_val);
test_motor_efficiency = (test_val(:, 1).*test_val(:,2))./(test_val(:, 3).*test_val(:,4));

%I think these give actuator efficiency values
actuator_val = evaluateSymbolic ({Tload, theta_dot}, t_val);
test_actuator_efficiency = (actuator_val(:, 1).*actuator_val(:,2))./(test_val(:, 3).*test_val(:,4));

%plotting efficiency
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

function result = evaluateSymbolic (equations, val)
    syms t;

    result = zeros(numel(val), numel(equations));

    for i = 1:numel(equations)
        result(:,i) = double(subs(equations{i}, t, val));
    end
end







