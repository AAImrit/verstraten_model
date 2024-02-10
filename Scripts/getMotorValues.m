function [Tm, thetam_dot, I, V, index_regen] = getMotorValues (theta, theta_dot, theta_double_dot, Tload, const, t_val, ignore_motor_inductance, ignore_regen, benchtopMode, plotVal)
    %{
        get all motor values

        Args:
        theta (double[]) -> joint position equation
        theta_dot (double[]) -> joint velocity equation
        theta_double_dot (double[]) -> joing acceleration equation
        Tload (double[]) -> external load on joint equation
        const (dict) -> constants of the equations
        t_val (double[]) -> range of values to evaluate our double[] over
        ignore_motor_inductance (bool) -> whether to ignore L or not
        benchtopMode (bool) -> whether the calculation is done for benchtop validation or just for an input function
        plotVal (bool) -> plot the output values of this function

        Returns:
        Tm (double[]) -> motor torque values over t_val
        thetam_dot (double[]) -> morot velocity values over t_val
        I (double[]) -> motor current values over t_val
        V (double[]) -> morot voltage over t_val
        index_regen (int[]) -> indices where regen occurs
    %}

    if benchtopMode == true
        ignore_motor_inductance = true;
        theta_double_dot = zeros(numel(Tload), 1);
    end
    
    Tm = getTm (Tload, theta_double_dot, const, 1/const('gear_efficiency'));
    index_regen = [];
    if ignore_regen == false
        index_regen = find( (theta_dot > 0 & Tload < 0) | (theta_dot < 0 & Tload > 0)); %get indices when in quadrant 2 or quadrant 4
        if (size(index_regen) ~= 0) %accounting for times when there simply isn't regeneration
            disp("regen accounted for in motor calc")
            Tm(index_regen) = getTm (Tload(index_regen), theta_double_dot(index_regen), const, const('gear_efficiency')); %overwrting regen_index with new Tm
        end
    end
    
    thetam_dot = const('gear_ratio').*theta_dot;

    I = (1/const('k_t')).*(Tm + const('motor_damping').*thetam_dot);
    
    V = const('motor_resistance').*I + const('k_b').*thetam_dot;

    if ignore_motor_inductance == false
        disp ("motor inductance accounted for")
        %approximating differential of I
        diff_I = numericDiff(I, t_val);
        V = V + const('motor_inductance').*diff_I;
    end
    
    if plotVal == true
        plotMotorVal (I, V, thetam_dot, Tm, t_val)
    end
end

function Tm = getTm (Tload, theta_double_dot, const, c)
    %{
        calculates Tm with C being changeable

        Args:
        Tload (double[]) -> the Tload values in a 1d array
        theta_double_dot (double[]) -> the theta double dot values in a 1D array
        const (dict) -> the constants of the equations
        c (double) -> the parameter that changes based on motor quadrant of operation

        Returns:
        Tm (double[]) -> Tm values in a 1D array
    %}

    Tm = (const('motor_inertia') + const('gear_inertia')).*const('gear_ratio').*theta_double_dot + (c/const('gear_ratio')).*Tload;
end 

function plotMotorVal (I, V, thetam_dot, Tm, t_val)
   figure('windowstyle','docked');
    plot (t_val, I, 'DisplayName', 'Current', 'color', 'r', 'LineWidth', 1)
    hold on;
    plot (t_val, V, 'DisplayName', 'Voltage', 'color', 'b')
    hold on;
    plot (t_val, Tm, 'DisplayName', 'Motor Torque', 'color', 'green')
    hold on;
    plot (t_val, thetam_dot, 'DisplayName', 'Thetam_dot', 'color', 'cyan')
    hold on;

    xlabel('Time (s)');
    ylabel ('Amps - Volts - Nm - rad/s');
    legend ('show');
    title("Motor Values")
end