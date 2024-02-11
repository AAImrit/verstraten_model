function [theta, t_val, theta_dot, theta_double_dot, Tload] = getBioData (Normalized, subject, trial, speed, incline, mass)
%{
    extract specific biomechanics data from the dataset
    2 return options, when mass=0, only gets theta and t_val from the biomechanics data, else get everything from the biomechanics data

    Args:
    Normalized (dataframe) -> dataset we are taking info from
    subject (string) -> subject we are extracting info for
    trial (string) -> the trial (run, stair, walk) we are extracting data for
    speed (string) -> the speed of the 
    incline (string) -> the incline
    mass (string) -> the mass of the 1 joint + 1 link

    Return:
    theta (double[]) -> the joing position
    theta_dot (double[]) -> the joint velocity
    theta_double_dot (double[]) -> the joint acceleration
    Tload (double[]) -> get Tload as a symbolic function
    t_val (double[]) -> get the timing for the human gait cycle

%}
    %filename = ["Normalized.mat", "Streaming.mat"];
    if (checkValid(subject, trial, speed, incline) == false)
        theta = 0;
        t_val = 0;
        return;
    end
    
    theta_dot = 0;
    theta_double_dot = 0;
    Tload = 0;

    %load(dataPath + filename(1));
    task = Normalized.(subject).(trial).(speed).(incline);

    %get t_val values
    strideDetails = task.events.StrideDetails;
    t_val = linspace(0, mean(strideDetails(:, 3)), 150);

    %get theta_values
    kneeAngle = task.jointAngles.KneeAngles;
    theta = mean(kneeAngle(:,1,:), 3); %taking average over all stride in that trial for that subject
    theta = theta*(pi/180); %converting theta from deg to rad
    
    if mass ~= 0
        [theta_dot, theta_double_dot, Tload] = getBioOutputShaft(task, t_val, mass);
    end

end 

function result = checkValid(subject, trial, speed, incline)
    %{
        check if the requested is one of the data that is not available in the dataset

        Args:
        subject (string) ->  sunject of the trial
        trial (string) -> which trial (walk, run, stair)
        speed (string) -> speed of the trial
        incline (string) -> incline of the trial

        Return:
        result (bool) -> true for exists, false for no

    %}

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
    %{
        gets the other output shaft values from the biomechanics data

        Args:
        task (dataframe) -> the specific trial we are working with
        t_val (double[]) -> the timing of the stride
        mass (double) -> mass of joint + link

        Return:
        theta_dot (double[]) -> output shaft angular speed = joinPower/jointMoment
        theta_double_dot (double[]) -> output shaft angular acceleration
        Tload (double[]) -> output shaft load = jointMoment
    %}

    knee_torque = task.jointMoments.KneeMoment;
    knee_torque = mean(knee_torque(:,1,:), 3);
    
    knee_power = task.jointPowers.KneePower;
    knee_power = mean(knee_power(:,1,:), 3);
    
    
    Tload = mass*knee_torque;
    theta_dot = knee_power ./ knee_torque; %since power = torque*angular velocity
    theta_double_dot = numericDiff(theta_dot, t_val);
end