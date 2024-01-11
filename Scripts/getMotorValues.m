function [Tm, thetam_dot, I, V] = getMotorValues (theta, theta_dot, theta_double_dot, Tload, const, t_val, ignore_motor_inductance)
    %{
        get all motor values

        Args:
        theta (symbolic function) -> joint position equation
        theta_dot (symbolic fucntion) -> joint velocity equation
        theta_double_dot (symbolic fucntion) -> joing acceleration equation
        Tload (symbolic function) -> external load on joint equation
        const (dict) -> constants of the equations
        t_val (double[]) -> range of values to evaluate our symbolic function over
        ignore_motor_inductance (bool) -> whether to ignore L or not

        Returns:
        Tm (double[]) -> motor torque values over t_val
        thetam_dot (double[]) -> morot velocity values over t_val
        I (double[]) -> motor current values over t_val
        V (double[]) -> morot voltage over t_val
    %}

    output_shaft_val = evaluateSymbolic ({theta, theta_dot, theta_double_dot, Tload}, t_val);
    
    %Tm = getTm (Tload, theta_double_dot, const, 1/const('gear_efficiency))
    %index_regen = something
    %Tm(index_regen) = getTm (Tlaod(index_regen), theta_double_dot(index_regen), const, const('gear_efficiency))
    Tm = getTm (output_shaft_val(:, 4), output_shaft_val(:, 3), const, 1/const('gear_efficiency'));

    thetam_dot = const('gear_ratio')*output_shaft_val(:,2);

    I = (1/const('k_t')) * (Tm + const('motor_damping').*thetam_dot);
    
    V = const('motor_resistance')*I + const('k_b')*thetam_dot;
    if ignore_motor_inductance == False
        diff_I = "something"; %use numerical methods to calculate this
        V = V + dconst('motor_inductance')*diff_I;
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

    Tm = (const('motor_inertia') + const('gear_inertia'))*const('gear_ratio').*theta_double_dot + (c/const('gear_ratio')).*Tload;
end 