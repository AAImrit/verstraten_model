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

benchtopMode = false; %benchtop mode allows for dicrete value input for theta_dot

%obtain contant values
currentPath = fileparts(fileparts(which(mfilename)));
constPath = currentPath + "\constant.txt"; %for matlab online, change "\constant.txt" to "/constant.txt"
dataPath = currentPath + "\Data\";

const = txtToDict(constPath);

%define theta and the equations
syms t;

% input testing ----------------------------------
%theta = 2*asin(sin(pi/8)*ellipj(t, sin(pi/8)));
%theta  = sin(t);
%theta_dot = heaviside(t);
%t_val = (linspace(0, 4*pi, 150));
%theta = (sin(t_val))';
%------------------------

[theta, theta_dot, theta_double_dot, Tload] = getOutputShaft (theta, 0, 0, const, t_val, benchtopMode, true);

%for benchtopMode == true, getOutput(0, [array of vectorValues, [array of T_driven values]])

[Tm, thetam_dot, I, V, index_regen] = getMotorValues (theta, theta_dot, theta_double_dot, Tload, const, t_val, false, false, benchtopMode, true);

test_motor_efficiency = getEfficiency(Tm, thetam_dot, I, V, index_regen, true);
test_actuator_efficiency = getEfficiency(Tload, theta_dot, I, V, index_regen, true);

%------------------------------------------PLOTTING---------------------------------------------------
%plotting I, V, theta,thetam_dot, theta_dot, Tload, Tm to compare and see if something looks off
figure('windowstyle','docked');
plot (t_val, I, 'DisplayName', 'Current', 'color', 'r', 'LineWidth', 1)
hold on;
plot (t_val, V, 'DisplayName', 'Voltage', 'color', 'b')
hold on;
plot (t_val, Tm, 'DisplayName', 'Motor Torque', 'color', 'green')
hold on;
plot (t_val, thetam_dot, 'DisplayName', 'Thetam_dot', 'color', 'cyan')
hold on;
plot (t_val, theta, '--', 'DisplayName', 'joint position', 'color', 'blue')
hold on;
plot (t_val, Tload, 'DisplayName', 'Tload', 'color', 'black')
hold on;
plot (t_val, theta_dot, 'DisplayName', 'Theta dot', 'color', 'magenta')
hold on;
plot (t_val, theta_double_dot, 'DisplayName', 'Theta double dot', 'color', 'yellow')
hold on;
scatter(t_val(index_regen), zeros(numel(t_val(index_regen)), 1),10, 'DisplayName', 'regen area','MarkerFaceColor', 'yellow');

xlabel('Time (s)');
ylabel ('Efficiency / Efficiency Error');
legend ('show');
title("I, V, Tload, Theta, Tm comparison")
%ylim([-5, 5]);

% plotting efficiency vs time
plotEfficiecny(test_motor_efficiency, t_val, theta, 'motor efficiency', index_regen, true)
plotEfficiecny(test_actuator_efficiency, t_val, theta, 'actuator efficiency', index_regen, true)

%extra plotting
plotEfficiecny(test_actuator_efficiency, t_val, theta, 'actuator efficiency', index_regen, false)
test_actuator_efficiency = getEfficiency(Tload, theta_dot, I, V, index_regen, false);
plotEfficiecny(test_actuator_efficiency, t_val, theta, 'actuator efficiency', index_regen, true)


function plotEfficiecny (efficiency, t_val, theta, name, index_regen, plot_theta)
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
    if plot_theta == true
        plot (t_val, theta, '--', 'DisplayName', 'Theta(t)', 'color', 'blue')
        hold on;
    end
    plot (t_val, movmean(efficiency, 10), 'DisplayName', 'moving average', 'color', 'r', 'LineWidth', 1.5)
    hold on;
    scatter(t_val(index_regen), zeros(numel(t_val(index_regen)), 1),10, 'DisplayName', 'regen area','MarkerFaceColor', 'yellow');
    
    title(name);
    xlabel('Time (s)');
    ylabel ('Efficiency');
    legend ('show');
    %ylim ([-2, 2]);
end

