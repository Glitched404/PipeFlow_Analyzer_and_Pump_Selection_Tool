function pump_db = create_pump_database()
    %% CREATE PUMP DATABASE
    % Creates database of 10 centrifugal pumps with performance curves
    % Data based on typical industrial pump characteristics
    %
    % Output:
    %   pump_db - Array of structures (1x10) with fields:
    %       .name - Pump model identifier
    %       .type - Pump type (Sanitary, Industrial, High-Head)
    %       .power_hp - Rated power (HP)
    %       .power_kW - Rated power (kW)
    %       .curve_Q - Flow rates (L/s)
    %       .curve_H - Heads (m)
    %       .curve_efficiency - Efficiencies (0-1)
    %       .Q_BEP - Best efficiency point flow (L/s)
    %       .H_BEP - Best efficiency point head (m)
    %       .efficiency_BEP - Best efficiency (0-1)
    %       .H_shutoff - Shutoff head at Q=0 (m)
    %       .Q_max - Maximum flow at H=0 (L/s)
    %
    % Reference:
    %   Based on typical centrifugal pump curves from manufacturers
    
    % PUMP 1: Small Sanitary Pump (1 HP / 0.75 kW)
    pump_db(1).name = 'FPX-1510';
    pump_db(1).type = 'Sanitary';
    pump_db(1).power_hp = 1.0;
    pump_db(1).power_kW = 0.75;
    pump_db(1).curve_data = [
        % Q(L/s)  H(m)   Efficiency(%)
        0.0,     22.0,   0.0;
        1.0,     20.8,   35.0;
        2.0,     18.5,   64.0;
        2.5,     16.8,   72.0;
        3.0,     14.8,   75.0;
        4.0,     9.8,    65.0;
        5.0,     3.5,    32.0
    ];
    
    % PUMP 2: Medium Sanitary Pump (2 HP / 1.5 kW)
    pump_db(2).name = 'FPX-1520';
    pump_db(2).type = 'Sanitary';
    pump_db(2).power_hp = 2.0;
    pump_db(2).power_kW = 1.5;
    pump_db(2).curve_data = [
        0.0,     28.0,   0.0;
        2.0,     26.0,   42.0;
        4.0,     22.5,   68.0;
        6.0,     17.2,   78.0;
        8.0,     10.5,   68.0;
        10.0,    3.0,    28.0
    ];
    
    % PUMP 3: Standard Industrial (3 HP / 2.2 kW)
    pump_db(3).name = 'FPX-2020';
    pump_db(3).type = 'Industrial';
    pump_db(3).power_hp = 3.0;
    pump_db(3).power_kW = 2.2;
    pump_db(3).curve_data = [
        0.0,     32.0,   0.0;
        3.0,     30.5,   45.0;
        6.0,     28.0,   65.0;
        10.0,    24.0,   76.0;
        12.0,    20.5,   80.0;
        15.0,    14.0,   72.0;
        18.0,    5.0,    42.0
    ];
    
    % PUMP 4: Medium Industrial (5 HP / 3.7 kW)
    pump_db(4).name = 'FPX-2030';
    pump_db(4).type = 'Industrial';
    pump_db(4).power_hp = 5.0;
    pump_db(4).power_kW = 3.7;
    pump_db(4).curve_data = [
        0.0,     38.0,   0.0;
        5.0,     36.5,   48.0;
        10.0,    34.0,   68.0;
        15.0,    30.5,   77.0;
        20.0,    26.0,   82.0;
        25.0,    19.5,   78.0;
        30.0,    11.0,   65.0;
        35.0,    3.0,    35.0
    ];
    
    % PUMP 5: Large Industrial (7.5 HP / 5.5 kW)
    pump_db(5).name = 'FPX-3040';
    pump_db(5).type = 'Industrial';
    pump_db(5).power_hp = 7.5;
    pump_db(5).power_kW = 5.5;
    pump_db(5).curve_data = [
        0.0,     45.0,   0.0;
        8.0,     43.0,   50.0;
        15.0,    40.0,   70.0;
        22.0,    36.0,   79.0;
        30.0,    30.5,   83.0;
        35.0,    24.0,   81.0;
        40.0,    16.0,   72.0;
        45.0,    6.0,    48.0
    ];
    
    % PUMP 6: High-Head Small (3 HP / 2.2 kW)
    pump_db(6).name = 'FPH-1530';
    pump_db(6).type = 'High-Head';
    pump_db(6).power_hp = 3.0;
    pump_db(6).power_kW = 2.2;
    pump_db(6).curve_data = [
        0.0,     55.0,   0.0;
        2.0,     52.0,   42.0;
        4.0,     48.0,   62.0;
        6.0,     42.5,   74.0;
        8.0,     35.0,   78.0;
        10.0,    25.0,   70.0;
        12.0,    12.0,   48.0
    ];
    
    % PUMP 7: High-Head Medium (5 HP / 3.7 kW)
    pump_db(7).name = 'FPH-2040';
    pump_db(7).type = 'High-Head';
    pump_db(7).power_hp = 5.0;
    pump_db(7).power_kW = 3.7;
    pump_db(7).curve_data = [
        0.0,     68.0,   0.0;
        3.0,     65.0,   44.0;
        6.0,     60.0,   64.0;
        10.0,    53.0,   75.0;
        12.0,    47.0,   80.0;
        15.0,    38.0,   78.0;
        18.0,    26.0,   68.0;
        20.0,    15.0,   50.0
    ];
    
    % PUMP 8: High Flow (7.5 HP / 5.5 kW)
    pump_db(8).name = 'FPX-4050';
    pump_db(8).type = 'High-Flow';
    pump_db(8).power_hp = 7.5;
    pump_db(8).power_kW = 5.5;
    pump_db(8).curve_data = [
        0.0,     35.0,   0.0;
        10.0,    33.5,   52.0;
        20.0,    31.0,   70.0;
        30.0,    27.5,   78.0;
        40.0,    23.0,   82.0;
        50.0,    17.5,   80.0;
        60.0,    11.0,   70.0;
        70.0,    4.0,    45.0
    ];
    
    % PUMP 9: Extra High-Head (7.5 HP / 5.5 kW)
    pump_db(9).name = 'FPH-3050';
    pump_db(9).type = 'High-Head';
    pump_db(9).power_hp = 7.5;
    pump_db(9).power_kW = 5.5;
    pump_db(9).curve_data = [
        0.0,     85.0,   0.0;
        4.0,     82.0,   46.0;
        8.0,     77.0,   66.0;
        12.0,    70.0,   76.0;
        16.0,    61.0,   81.0;
        20.0,    50.0,   79.0;
        24.0,    36.0,   72.0;
        28.0,    20.0,   58.0
    ];
    
    % PUMP 10: Large High-Flow (10 HP / 7.5 kW)
    pump_db(10).name = 'FPX-5060';
    pump_db(10).type = 'High-Flow';
    pump_db(10).power_hp = 10.0;
    pump_db(10).power_kW = 7.5;
    pump_db(10).curve_data = [
        0.0,     40.0,   0.0;
        15.0,    38.5,   54.0;
        30.0,    36.0,   72.0;
        45.0,    32.5,   80.0;
        60.0,    28.0,   84.0;
        75.0,    22.0,   82.0;
        90.0,    14.5,   74.0;
        105.0,   6.0,    52.0
    ];
    
    % Post-process all pumps to extract key parameters
    for i = 1:length(pump_db)
        Q = pump_db(i).curve_data(:, 1);
        H = pump_db(i).curve_data(:, 2);
        eff = pump_db(i).curve_data(:, 3) / 100;  % Convert to 0-1
        
        % Store curve data
        pump_db(i).curve_Q = Q;
        pump_db(i).curve_H = H;
        pump_db(i).curve_efficiency = eff;
        
        % Find best efficiency point (BEP)
        [max_eff, idx_bep] = max(eff);
        pump_db(i).Q_BEP = Q(idx_bep);
        pump_db(i).H_BEP = H(idx_bep);
        pump_db(i).efficiency_BEP = max_eff;
        
        % Shutoff head and max flow
        pump_db(i).H_shutoff = H(1);
        pump_db(i).Q_max = Q(end);
        
        % Calculate specific speed (dimensionless)
        % Ns = (N * sqrt(Q)) / H^(3/4), assuming N = 1750 RPM
        N_rpm = 1750;
        if pump_db(i).H_BEP > 0
            pump_db(i).specific_speed = (N_rpm * sqrt(pump_db(i).Q_BEP)) / ...
                                        (pump_db(i).H_BEP^0.75);
        else
            pump_db(i).specific_speed = 0;
        end
    end
end
