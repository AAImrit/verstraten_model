function [tstep_noRegen, tstep_regen] = tstepCalc (I_noRegen, V_noRegen, I_regen, V_regen, index_regen, battey_cap, eff_regen)
    %{

    Args:
    I_noRegen (double[]) -> current of actuator when regen is not accounted for
    V_noRegen (double[]) -> voltage od actuator when regen is not accounted for
    I_regen (double[]) -> current of actuator when regen is accounted for
    V_regen (double[]) -> voltage of actuator when regen is accounted for
    battery_cap (double) -> total battery capacity 
    eff_regen (double[]) -> efficiencies through human gait cycle of actuator when regen is accounted more

    Returns:
    tstep_noRegen (double) -> the amount of steps made when regen is turned off
    tstep_regen (double) -> the amount of steps when regen is accounted for
    
    %}

    tstep_noRegen = ( battey_cap / sum(I_noRegen.*V_noRegen) ) / 2;

    eff_negative_regen = find (eff_regen(index_regen) > 0);
    power_regen = sum(I_regen(eff_negative_regen).*V_regen(eff_negative_regen));
    power_consumed = sum(I_regen(~eff_negative_regen).*V_regen(~eff_negative_regen));
    tstep_regen = ( battey_cap / (power_consumed - power_regen) ) / 2;

end