%{
benchtopMode == true will need a different main file because of the t_val
stuff, t_val does not apply for benchtop validation, it only applies for
when a function is known

This file is used to "test" the outputs of the simulation and see if the
results make sense
%}

close all;
clear all;
clc;

benchtopMode = false; 

%obtain contant values
currentPath = which(mfilename);
constPath = fileparts(fileparts(currentPath))+ "\constant.txt"; %for matlab online, change \constant to /constant
const = txtToDict(constPath);

%define theta and the equations
syms t;
t_val = linspace(0, 4*pi, 1000);
[theta, theta_dot, theta_double_dot, Tload] = getOutputShaft (sin(t), 0, 0, const, t_val, benchtopMode);
%changing from symbolic to numerical
output_shaft_val = evaluateSymbolic ({theta, theta_dot, theta_double_dot, Tload}, t_val);
theta = output_shaft_val(:, 1);
theta_dot = output_shaft_val(:, 2);
theta_double_dot = output_shaft_val(:, 3);
Tload = output_shaft_val(:, 4);

%for benchtopMode == true, getOutput(0, [array of vectorValues, [array of T_driven values]])

[Tm, thetam_dot, I, V, index_regen] = getMotorValues (theta, theta_dot, theta_double_dot, Tload, const, t_val, false, false, benchtopMode);

test_motor_efficiency = getEfficiency(Tm, thetam_dot, I, V, index_regen, true);
test_actuator_efficiency = getEfficiency(Tload, theta_dot, I, V, index_regen, true);

%------------------------------------------PLOTTING---------------------------------------------------
% plotting efficiency vs time
plotEfficiecny(test_motor_efficiency, t_val, theta, 'motor efficiency')
plotEfficiecny(test_actuator_efficiency, t_val, theta, 'actuator efficiency')

%plotting I, V, theta, Tload, Tm to compare and see if something looks off
figure('windowstyle','docked');
plot (t_val, I, 'DisplayName', 'Current', 'color', 'r', 'LineWidth', 1)
hold on;
plot (t_val, V, 'DisplayName', 'Voltage', 'color', 'b')
hold on;
plot (t_val, theta, '--', 'DisplayName', 'joint position', 'color', 'blue')
hold on;
plot (t_val, Tm, 'DisplayName', 'Motor Torque', 'color', 'green')
hold on;
plot (t_val, Tload, 'DisplayName', 'Tload', 'color', 'black')

xlabel('Time (s)');
ylabel ('Efficiency / Efficiency Error');
legend ('show');
title("I, V, Tload, Theta, Tm comparison")
%ylim([-5, 5]);

%Looking at difference between motor efficiency and actuator efficiency
figure('windowstyle','docked');
plot (t_val, test_motor_efficiency, 'DisplayName', 'Motor Efficiency', 'color', [0.2 0.5 0.9 0.4], 'LineWidth', 2)
hold on;
plot (t_val, test_actuator_efficiency, 'DisplayName', 'Actuator Efficiency', 'color', 'red', 'LineWidth', 0.5)
hold on;
plot (t_val, abs((test_actuator_efficiency-test_motor_efficiency)./test_motor_efficiency), 'DisplayName', 'Difference', 'color', 'black', 'LineWidth', 1)
hold on;
plot (t_val, theta, '--', 'DisplayName', 'Theta(t)', 'color', 'blue')

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
    plot (t_val, movmean(efficiency, 100), 'DisplayName', 'moving average', 'color', 'r', 'LineWidth', 1.5)
    
    title(name);
    xlabel('Time (s)');
    ylabel ('Efficiency');
    legend ('show');
    %ylim ([-5, 5]);
end

function eff = getEfficiency(torque, velocity, current, voltage, regen_index, remove_inf)
    %{
        get efficiency and applies the quadrant logic

        Args:
        torque (double[]) -> torque values over some rane
        velocity (double[]) ->velocity values over some rane
        current (double[]) -> current values over some rane
        voltage (double[]) -> voltage values over some rane
        regen_index (int[]) -> indices where regen occurs
        remove_inf (bool) -> bool that indicates whether indices where eff is going to inf should be removed

        Return:
        eff (double[]) -> the efficiency over a given range
    %}
    eff = zeros(numel(torque), 1);
    eff = (torque.*velocity)./(current.*voltage);
    if (size(regen_index) ~= 0)
        disp("regen accounted for in efficiency calc")
        eff(regen_index) = (current(regen_index).*voltage(regen_index))./(torque(regen_index).*velocity(regen_index));
    end

    if remove_inf == true
        eff = removeEffDiscontinuity(eff);
        disp ("efficiency discontinuity removed")
    end
end

function eff = removeEffDiscontinuity (eff)
    %{
    %Method 1 
    regen_inf_index = find (velocity == 0 | torque == 0); 
    regen_inf_index = regen_inf_index(ismember(regen_inf_index, regen_index));
    eff(regen_inf_index) = eff(regen_inf_index-1);

    notregen_inf_index = find (current == 0 | voltage == 0);
    notregen_inf_index = notregen_inf_index(~ismember(notregen_inf_index, regen_index));
    eff(notregen_inf_index) = eff(notregen_inf_index-1);
    %}

    %Method 2: for all indices where eff > 2, let that eff = last eff where it was less than 2
    %
    inf_index = find(abs(eff)>2);
    last_val = eff(inf_index(1)-1);
    eff(inf_index(1)) = last_val;
    
    for i = 2:numel(inf_index)
        if(inf_index(i) == (inf_index(i-1)+1))
            eff(inf_index(i)) = last_val;
        else
            last_val = eff(inf_index(i)-1);
            eff(inf_index(i)) = last_val;
        end
    end
    
    %could also do eff(inf_index) = 2;

end




