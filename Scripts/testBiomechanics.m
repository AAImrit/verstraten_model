%{
This file is used to "test" with biomechemanics data the outputs of the simulation and see if the
results make sense
%}

close all;
%clear all;
clearvars -except Normalized;
clc;

benchtopMode = false; %benchtop mode allows for dicrete value input for theta_dot

%obtain contant values
currentPath = fileparts(fileparts(which(mfilename)));
constPath = currentPath + "\constant.txt"; %for matlab online, change "\constant.txt" to "/constant.txt"
dataPath = currentPath + "\Data\";

const = txtToDict(constPath);

%define theta and the equations
%{
subjects = ['AB01', 'AB02', 'AB03', 'AB04', 'AB05', 'AB06', 'AB07', 'AB08', 'AB09', 'AB10'];
trials = ["Run", "Walk", "Stairs"]
walkSpeed = [a0x2, a0x5, d0x2, d0x5, s0x8, s1, s1x2]
runSpeed = [a0x2, a0x5, d0x2, d0x5, s1x8, s2x0, s2x2, s2x4]
walkIncline = [i0, i5, i10, in5, in10]
runIncline = [i0]
%}



%------------------------

% this one is when we are estimating everything else
%[theta, t_val, theta_dot, theta_double_dot, Tload] = getBioData (dataPath, 'AB03', 'Walk', 's1', 'i0', 0);
%[theta, theta_dot, theta_double_dot, Tload] = getOutputShaft (theta, 0, 0, const, t_val, benchtopMode, true);

%this one I'm taking values directly from the data
if ~exist('Normalized', 'var')
    disp('loading normalized data');
    load(dataPath + "Normalized.mat");
    disp('loaded normalized data');
end

[theta, t_val, theta_dot, theta_double_dot, Tload] = getBioData (Normalized, 'AB03', 'Walk', 's1', 'i0', const('mass'));
plotOutputShaft (theta, theta_dot, theta_double_dot, Tload, t_val)
[Tm, thetam_dot, I, V, index_regen] = getMotorValues (theta, theta_dot, theta_double_dot, Tload, const, t_val, false, false, benchtopMode, true);
[Tm2, thetam_dot2, I2, V2, index_regen2] = getMotorValues (theta, theta_dot, theta_double_dot, Tload, const, t_val, false, true, benchtopMode, false);

test_motor_efficiency = getEfficiency(Tm, thetam_dot, I, V, index_regen, true);
test_actuator_efficiency = getEfficiency(Tload, theta_dot, I, V, index_regen, true);

battery_cap = 967690;
[tstep_noRegen, tstep_regen] = getTstep (I2, V2, I, V, index_regen, battey_cap, eff)

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

function plotOutputShaft (theta, theta_dot, theta_double_dot, Tload, t_val)
    figure('windowstyle','docked');
    plot (t_val, theta, '--', 'DisplayName', 'joint position', 'color', 'blue')
    hold on;
    plot (t_val, Tload, 'DisplayName', 'Tload', 'color', 'black')
    hold on;
    plot (t_val, theta_dot, 'DisplayName', 'Theta_dot', 'color', 'magenta')
    hold on;
    plot (t_val, theta_double_dot, 'DisplayName', 'Theta_double_dot', 'color', 'green')
    
    xlabel('Time (s)');
    ylabel ('Nm - rad - rad/s - rad/s^2');
    legend ('show');
    title("Output Shaft Values")
end

