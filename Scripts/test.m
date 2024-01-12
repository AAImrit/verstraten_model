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

%get Tm, thetam_dot, efficiency values
t_val = linspace(0, 4*pi, 100);

[Tm, thetam_dot, I, V, index_regen] = getMotorValues (theta, theta_dot, theta_double_dot, Tload, const, t_val, false, false);
test_motor_efficiency = getEfficiency(Tm, thetam_dot, I, V, index_regen);

actuator_val = evaluateSymbolic ({Tload, theta_dot}, t_val);
test_actuator_efficiency = getEfficiency(actuator_val(:, 1), actuator_val(:,2), I, V, index_regen);

%plotting efficiency
plotEfficiecny(test_motor_efficiency, t_val, double(subs(theta,t,t_val)), 'motor efficiency')
plotEfficiecny(test_actuator_efficiency, t_val, double(subs(theta,t,t_val)), 'actuator efficiency')

figure('windowstyle','docked');
plot (t_val, I, 'DisplayName', 'Current', 'color', 'r', 'LineWidth', 1)
hold on;
plot (t_val, I, 'DisplayName', 'Voltage', 'color', 'b')
hold on;
plot (t_val, double(subs(theta,t,t_val)), '--', 'DisplayName', 'joint position', 'color', 'blue')
hold on;
plot (t_val, Tm, 'DisplayName', 'Motor Torque', 'color', 'green')
hold on;
plot (t_val, actuator_val(:, 1), 'DisplayName', 'Tload', 'color', 'black')

legend ('show')
xlabel('Time (s)');
ylabel ('Efficiency / Efficiency Error');
legend ('show');
%ylim([-5, 5]);

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
%ylim([-5, 5]);

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
    plot (t_val, movmean(efficiency, 10), 'DisplayName', 'moving average', 'color', 'r', 'LineWidth', 1.5)
    
    title(name);
    xlabel('Time (s)');
    ylabel ('Efficiency');
    legend ('show');
    %ylim ([-5, 5]);
end

function eff = getEfficiency(torque, velocity, current, voltage, regen_index)
    %{
        get efficiency and applies the quadrant logic

        Args:
        torque (double[]) -> torque values over some rane
        velocity (double[]) ->velocity values over some rane
        current (double[]) -> current values over some rane
        voltage (double[]) -> voltage values over some rane
        regen_index (int[]) -> indices where regen occurs

        Return:
        eff (double[]) -> the efficiency over a given range
    %}
    eff = zeros(numel(torque), 1);
    eff = (torque.*velocity)./(current.*voltage);
    if (size(regen_index) ~= 0)
        disp("regen accounted for in efficiency calc")
        eff(regen_index) = (current(regen_index).*voltage(regen_index))./(torque(regen_index).*velocity(regen_index));
    end
end





