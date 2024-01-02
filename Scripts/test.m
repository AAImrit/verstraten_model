%obtain contant values
currentPath = which(mfilename);
constantPath = fileparts(fileparts(currentPath))+ "\constant.txt";
constant = txtToDict(constantPath);


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
syms t

theta = sin(t);
theta_dot = diff(theta, t);
theta_double_dot = diff(theta_dot, t);

%{
    issues with simples case:
    - can't really make a heatmap out of this, will only get specific thetam_dot, Tm values
    - remeber for heatmap, motor velocity is independent variable, motor torque is non independent
%}



