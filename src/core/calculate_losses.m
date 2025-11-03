function results = calculate_losses(inputs)
    %% MAIN CALCULATION ENGINE
    % Calculates all losses, pump requirements, and generates system curves
    %
    % Input:
    %   inputs - Structure with fields:
    %       .pipe (diameter, length, roughness, material, material_name)
    %       .fittings (array with type, K, position, name)
    %       .flow (Q, V, temperature, rho, mu, method)
    %       .system (z_inlet, z_outlet, P_inlet, P_outlet)
    % Output:
    %   results - Structure with all calculated parameters including:
    %       .flow (Q, V, Re, regime)
    %       .friction (f, h_f, dP_f)
    %       .minor_losses (K_total, h_m, dP_m, details)
    %       .total_losses (h_L, dP_total)
    %       .system_curve (Q_range, H_range, K_sys)
    %       .pump_selection (name, Q_op, H_op, efficiency, curves)
    %       .power (hydraulic, shaft, motor)
    %       .egl_hgl (x, EGL, HGL, elevation)
    %       .moody (Re, eps_D, f)
    
    % Extract input parameters
    D = inputs.pipe.diameter;        % Pipe diameter (m)
    L = inputs.pipe.length;          % Pipe length (m)
    eps = inputs.pipe.roughness;     % Absolute roughness (m)
    Q = inputs.flow.Q;               % Flow rate (m³/s)
    rho = inputs.flow.rho;           % Density (kg/m³)
    mu = inputs.flow.mu;             % Dynamic viscosity (Pa·s)
    g = 9.81;                        % Gravitational acceleration (m/s²)
    
    % ═════════════════════════════════════════════════════════════════════
    % FLOW PROPERTIES
    % ═════════════════════════════════════════════════════════════════════
    
    % Calculate pipe cross-sectional area
    A = pi * D^2 / 4;
    
    % Calculate velocity
    V = Q / A;
    
    % Calculate Reynolds number
    Re = rho * V * D / mu;
    
    % Calculate relative roughness
    eps_D = eps / D;
    
    fprintf('Flow Properties:\n');
    fprintf('  Velocity: %.3f m/s\n', V);
    fprintf('  Reynolds: %.0f\n', Re);
    fprintf('  Relative roughness (ε/D): %.6f\n\n', eps_D);
    
    % ═════════════════════════════════════════════════════════════════════
    % FRICTION FACTOR (MOODY CHART METHOD)
    % ═════════════════════════════════════════════════════════════════════
    
    [f, regime] = get_f_from_moody_chart(Re, eps_D);
    
    fprintf('Friction Analysis:\n');
    fprintf('  Regime: %s\n', regime);
    fprintf('  Friction factor (f): %.4f\n\n', f);
    
    % ═════════════════════════════════════════════════════════════════════
    % MAJOR LOSSES (DARCY-WEISBACH EQUATION)
    % ═════════════════════════════════════════════════════════════════════
    
    % Head loss due to friction: h_f = f × (L/D) × (V²/2g)
    h_f = f * (L/D) * (V^2 / (2*g));
    
    % Pressure drop due to friction
    dP_f = rho * g * h_f;
    
    fprintf('Major Losses (Friction):\n');
    fprintf('  Head loss (h_f): %.3f m\n', h_f);
    fprintf('  Pressure drop (ΔP_f): %.1f kPa\n\n', dP_f/1000);
    
    % ═════════════════════════════════════════════════════════════════════
    % MINOR LOSSES (K-FACTOR METHOD)
    % ═════════════════════════════════════════════════════════════════════
    
    % Calculate total K-factor from all fittings
    K_total = 0;
    minor_loss_details = {};
    
    for i = 1:length(inputs.fittings)
        K_i = inputs.fittings(i).K;
        pos = inputs.fittings(i).position;
        name = inputs.fittings(i).name;
        
        K_total = K_total + K_i;
        
        % Store detail for report
        minor_loss_details{i} = sprintf('  %s at %.2f m: K = %.2f', name, pos, K_i);
    end
    
    % Total minor loss head: h_m = K_total × (V²/2g)
    h_m = K_total * (V^2 / (2*g));
    
    % Pressure drop due to minor losses
    dP_m = rho * g * h_m;
    
    fprintf('Minor Losses (Fittings):\n');
    fprintf('  Total K-factor: %.2f\n', K_total);
    fprintf('  Head loss (h_m): %.3f m\n', h_m);
    fprintf('  Pressure drop (ΔP_m): %.1f kPa\n\n', dP_m/1000);
    
    % ═════════════════════════════════════════════════════════════════════
    % TOTAL LOSSES
    % ═════════════════════════════════════════════════════════════════════
    
    h_L = h_f + h_m;
    dP_total = dP_f + dP_m;
    
    fprintf('Total Losses:\n');
    fprintf('  Head loss (h_L): %.3f m\n', h_L);
    fprintf('  Pressure drop (ΔP_total): %.1f kPa\n\n', dP_total/1000);
    
    % ═════════════════════════════════════════════════════════════════════
    % DISTRIBUTED LOSS PROFILE (for accurate pressure/EGL/HGL plots)
    % ═════════════════════════════════════════════════════════════════════
    
    % Calculate friction loss per meter
    dh_dx = f * (1/D) * (V^2 / (2*g));  % Head loss gradient (m/m)
    
    % Build profile with discrete drops at fittings
    % Strategy: For each fitting, add point before and after to show vertical drop
    x_profile = [];
    h_friction_cum = [];
    h_minor_cum = [];
    h_total_cum = [];
    
    % Start at inlet
    x_profile(1) = 0;
    h_friction_cum(1) = 0;
    h_minor_cum(1) = 0;
    h_total_cum(1) = 0;
    
    % Sort fittings by position (should already be sorted from input)
    [~, sort_idx] = sort([inputs.fittings.position]);
    fittings_sorted = inputs.fittings(sort_idx);
    
    % Process each segment between fittings
    current_pos = 0;
    idx = 1;
    
    for i = 1:length(fittings_sorted)
        fitting_pos = fittings_sorted(i).position;
        
        % Add point just before fitting (after friction loss up to this point)
        if fitting_pos > current_pos
            idx = idx + 1;
            x_profile(idx) = fitting_pos;
            % Friction loss from last position to here
            h_friction_cum(idx) = h_friction_cum(idx-1) + dh_dx * (fitting_pos - current_pos);
            h_minor_cum(idx) = h_minor_cum(idx-1);  % No minor loss yet
            h_total_cum(idx) = h_friction_cum(idx) + h_minor_cum(idx);
            
            % Add point just after fitting (with minor loss drop)
            idx = idx + 1;
            x_profile(idx) = fitting_pos;  % Same position
            h_friction_cum(idx) = h_friction_cum(idx-1);  % Same friction
            h_minor_cum(idx) = h_minor_cum(idx-1) + fittings_sorted(i).K * (V^2 / (2*g));  % Add minor loss
            h_total_cum(idx) = h_friction_cum(idx) + h_minor_cum(idx);
            
            current_pos = fitting_pos;
        end
    end
    
    % Add outlet point
    if L > current_pos
        idx = idx + 1;
        x_profile(idx) = L;
        h_friction_cum(idx) = h_friction_cum(idx-1) + dh_dx * (L - current_pos);
        h_minor_cum(idx) = h_minor_cum(idx-1);
        h_total_cum(idx) = h_friction_cum(idx) + h_minor_cum(idx);
    end
    
    % Store profile data
    profile.x = x_profile;
    profile.h_friction_cum = h_friction_cum;
    profile.h_minor_cum = h_minor_cum;
    profile.h_total_cum = h_total_cum;
    
    % ═════════════════════════════════════════════════════════════════════
    % BERNOULLI EQUATION - PUMP REQUIREMENT
    % ═════════════════════════════════════════════════════════════════════
    
    % Elevation difference
    dz = inputs.system.z_outlet - inputs.system.z_inlet;
    
    % Pressure difference
    dP_press = inputs.system.P_outlet - inputs.system.P_inlet;
    h_press = dP_press / (rho * g);
    
    % Required pump head (Extended Bernoulli)
    % h_pump = Δz + ΔP/(ρg) + h_L
    h_pump = dz + h_press + h_L;
    
    fprintf('Pump Requirement:\n');
    fprintf('  Static head (Δz): %.2f m\n', dz);
    fprintf('  Pressure head (ΔP/(ρg)): %.2f m\n', h_press);
    fprintf('  Loss head (h_L): %.2f m\n', h_L);
    fprintf('  Total required head: %.2f m @ %.1f L/s\n\n', h_pump, Q*1000);
    
    % ═════════════════════════════════════════════════════════════════════
    % SYSTEM CURVE GENERATION
    % ═════════════════════════════════════════════════════════════════════
    
    % System curve: H_sys(Q) = H_static + K_sys × Q²
    % K_sys is calculated from losses at design point
    K_sys = h_L / (Q^2);
    
    % Generate system curve over range 0 to 1.5× design flow
    Q_range = linspace(0, 1.5*Q, 50);
    H_sys = dz + h_press + K_sys * Q_range.^2;
    
    % ═════════════════════════════════════════════════════════════════════
    % PUMP SELECTION
    % ═════════════════════════════════════════════════════════════════════
    
    % Load pump database
    pump_db = load_pump_database();
    
    % Find best pump and operating point
    [pump_idx, Q_op, H_op, eff_op] = find_operating_point(pump_db, H_sys, Q_range, h_pump, Q);
    
    fprintf('Selected Pump: %s\n', pump_db(pump_idx).name);
    fprintf('  Type: %s\n', pump_db(pump_idx).type);
    fprintf('  Rated power: %.1f HP (%.1f kW)\n', ...
        pump_db(pump_idx).power_hp, pump_db(pump_idx).power_kW);
    fprintf('  Operating point: %.1f L/s @ %.1f m\n', Q_op*1000, H_op);
    fprintf('  Efficiency: %.1f%%\n\n', eff_op*100);
    
    % ═════════════════════════════════════════════════════════════════════
    % POWER CALCULATIONS
    % ═════════════════════════════════════════════════════════════════════
    
    % Hydraulic power: P_hydr = ρ × g × Q × h_pump
    P_hydr = rho * g * Q * h_pump / 1000;  % Convert to kW
    
    % Shaft power (accounting for pump efficiency)
    if eff_op > 0.01
        P_shaft = P_hydr / eff_op;
    else
        P_shaft = P_hydr / 0.70;  % Assume 70% if efficiency unknown
    end
    
    % Motor power (with 15% safety margin)
    P_motor = P_shaft * 1.15;
    
    fprintf('Power Requirements:\n');
    fprintf('  Hydraulic power: %.2f kW\n', P_hydr);
    fprintf('  Shaft power: %.2f kW\n', P_shaft);
    fprintf('  Motor power: %.2f kW (with 15%% safety margin)\n\n', P_motor);
    
    % ═════════════════════════════════════════════════════════════════════
    % ENERGY GRADE LINE (EGL) & HYDRAULIC GRADE LINE (HGL)
    % ═════════════════════════════════════════════════════════════════════
    
    [x_pos, EGL, HGL, elev] = calculate_egl_hgl(inputs, h_L, V, profile);
    
    % ═════════════════════════════════════════════════════════════════════
    % COMPILE RESULTS STRUCTURE
    % ═════════════════════════════════════════════════════════════════════
    
    results = struct();
    
    % Flow properties
    results.flow.Q = Q;
    results.flow.V = V;
    results.flow.Re = Re;
    results.flow.regime = regime;
    
    % Friction losses
    results.friction.f = f;
    results.friction.h_f = h_f;
    results.friction.dP_f = dP_f;
    
    % Minor losses
    results.minor_losses.K_total = K_total;
    results.minor_losses.h_m = h_m;
    results.minor_losses.dP_m = dP_m;
    results.minor_losses.details = minor_loss_details;
    
    % Total losses
    results.total_losses.h_L = h_L;
    results.total_losses.dP_total = dP_total;
    
    % System curve
    results.system_curve.Q_range = Q_range;
    results.system_curve.H_range = H_sys;
    results.system_curve.K_sys = K_sys;
    results.system_curve.H_static = dz + h_press;
    
    % Pump selection
    results.pump_selection.name = pump_db(pump_idx).name;
    results.pump_selection.type = pump_db(pump_idx).type;
    results.pump_selection.Q_operating = Q_op;
    results.pump_selection.H_operating = H_op;
    results.pump_selection.efficiency = eff_op;
    results.pump_selection.pump_curve_Q = pump_db(pump_idx).curve_Q;
    results.pump_selection.pump_curve_H = pump_db(pump_idx).curve_H;
    results.pump_selection.pump_curve_eff = pump_db(pump_idx).curve_efficiency;
    
    % Power
    results.power.hydraulic = P_hydr;
    results.power.shaft = P_shaft;
    results.power.motor = P_motor;
    
    % Energy lines
    results.egl_hgl.x = x_pos;
    results.egl_hgl.EGL = EGL;
    results.egl_hgl.HGL = HGL;
    results.egl_hgl.elevation = elev;
    
    % Moody chart data
    results.moody.Re = Re;
    results.moody.eps_D = eps_D;
    results.moody.f = f;
    
    % Distributed profile (for accurate spatial plotting)
    results.profile = profile;
    
    % Input parameters (for report generation)
    results.inputs = inputs;
end
