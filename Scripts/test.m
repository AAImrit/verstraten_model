close all;
clear all;
clc;

%obtain contant values
currentPath = which(mfilename);
constPath = fileparts(fileparts(currentPath))+ "\constant.txt"; %for matlab online, change \constant to /constant
const = txtToDict(constPath);

%define theta and the equations
syms t;
[theta, theta_dot, theta_double_dot, Tload] = getOutputShaft (sin(t), 0, 0, const);

%testing get Tm, thetam_dot, efficiency values
t_val = linspace(0, 4*pi, 100);

[Tm, thetam_dot, I, V] = getMotorValues (theta, theta_dot, theta_double_dot, Tload, const, t_val, true);
test_motor_efficiency = (Tm.*thetam_dot)./(I.*V);

actuator_val = evaluateSymbolic ({Tload, theta_dot}, t_val);
test_actuator_efficiency = (actuator_val(:, 1).*actuator_val(:,2))./(I.*V);

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








