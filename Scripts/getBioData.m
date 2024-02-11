function [theta, t_val, theta_dot, theta_double_dot, Tload] = getBioData (dataPath, subject, trial, speed, incline, mass)
%{
%}
    filename = ["Normalized.mat", "Streaming.mat"];
    if (checkValid(subject, trial, speed, incline) == false)
        theta = 0;
        t_val = 0;
        return;
    end
    
    theta_dot = 0;
    theta_double_dot = 0;
    Tload = 0;

    load(dataPath + filename(1));
    task = Normalized.(subject).(trial).(speed).(incline);

    %get t_val values
    strideDetails = task.events.StrideDetails;
    t_val = linspace(0, mean(strideDetails(:, 3)), 150);

    %get theta_values
    kneeAngle = task.jointAngles.KneeAngles;
    theta = mean(kneeAngle(:,1,:), 3);
    theta = theta*(pi/180); %converting theta from deg to rad
    
    if mass ~= 0
        [theta_dot, theta_double_dot, Tload] = getBioOutputShaft(task, t_val, mass);
    end

end 

function result = checkValid(subject, trial, speed, incline)
    result = true;
    if ((strcmp(subject, 'AB08') || strcmp(subject, 'AB10')) && strcmp(incline, 'i0'))
        if (strcmp(trial, 'Run') && strcmp(speed, 's2x4'))
            disp("Run trial does not exist for subject")
            result = false;
        elseif (strcmp(trial, 'Walk') && (strcmp(speed, 'a0x5') || strcmp(speed, 'd0x5')))
            disp ("Walk trial does not exist for subject")
            result = false;
        end
    end
end

function [theta_dot, theta_double_dot, Tload] = getBioOutputShaft(task, t_val, mass)

    knee_torque = task.jointMoments.KneeMoment;
    knee_torque = mean(knee_torque(:,1,:), 3);
    
    knee_power = task.jointPowers.KneePower;
    knee_power = mean(knee_power(:,1,:), 3);
    
    
    Tload = mass*knee_torque;
    theta_dot = knee_power ./ knee_torque; %since power = torque*angular velocity
    theta_double_dot = numericDiff(theta_dot, t_val);
end