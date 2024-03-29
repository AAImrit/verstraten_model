%{
Tries to replicate benchtop efficiency heatmap
V1: considers we know Tload and theta_dot
Potential Improvement: we know T_driven (the mglsin(theta)) and theta_dot,
then we solve for Tload, and try the rest
%}
close all;
clear all;
clc;

benchtopMode = true; %benchtop mode allows for dicrete value input for theta_dot

%obtain contant values
currentPath = fileparts(fileparts(which(mfilename)));
constPath = currentPath + "\constant.txt"; %for matlab online, change "\constant.txt" to "/constant.txt"
const = txtToDict(constPath);


%Tload = (linspace(-10, 10, 1000))'; 
%theta_dot = (linspace(-10, 10, 500))';

Tload = (linspace(-2.5, 2.5, 1000))'; 
theta_dot = (linspace(-0.2, 0.2, 500))';

theta_dot_temp = 1+zeros(numel(Tload),1);


eff = zeros(numel(Tload), numel(theta_dot));

for i = 1:numel(theta_dot)
    temp = theta_dot(i)*theta_dot_temp;
    [Tm, thetam_dot, I, V, index_regen] = getMotorValues (0,temp, 0, Tload, const, 0, false, false, benchtopMode, false);

    eff(:,i) = getEfficiency(Tload, temp, I, V, index_regen, false);
end

%Plotting the heatmap
figure('windowstyle','docked');
h = pcolor(theta_dot, Tload, eff);
set(h, 'EdgeColor', 'none');
colormap('jet');
colorbar;
caxis([-1, 1]);
hold on;
plot (theta_dot, zeros(numel(theta_dot),1), 'LineWidth', 1, 'color', 'black'); %horzontal line to distinguish b/w quadrant
hold on;
plot (zeros(numel(Tload),1),Tload, 'LineWidth', 1, 'color', 'black'); %vertical line to dinstinguish b/w quadrant

title('Efficiency Map');
xlabel('theta dot (rad/s)');
ylabel('Tload (Nm)');
grid off;
