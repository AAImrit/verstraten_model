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
    if (numel(inf_index) < 1)
        return;
    end
    
    last_val = 2;
    if (inf_index(1) ~= 1)
        last_val = eff(inf_index(1)-1);
    end
    eff(inf_index(1)) = last_val;
    
    for i = 2:numel(inf_index)
        if(inf_index(i) ~= (inf_index(i-1)+1))
            last_val = eff(inf_index(i)-1);
        end
        eff(inf_index(i)) = last_val;
    end
    
    %could also do eff(inf_index) = 2; or just remove these indices

end
