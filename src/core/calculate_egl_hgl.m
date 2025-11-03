function [x_pos, EGL, HGL, elevation] = calculate_egl_hgl(inputs, h_L, V, profile)
    %% CALCULATE ENERGY GRADE LINE (EGL) AND HYDRAULIC GRADE LINE (HGL)
    % Computes energy and hydraulic grade lines along pipe using profile data
    %
    % Input:
    %   inputs - Input structure with system configuration
    %   h_L - Total head loss (m)
    %   V - Velocity (m/s)
    %   profile - Structure with distributed loss profile (.x, .h_total_cum)
    % Output:
    %   x_pos - Position along pipe (m), variable length array
    %   EGL - Energy grade line (m), same length as x_pos
    %   HGL - Hydraulic grade line (m), same length as x_pos
    %   elevation - Pipe centerline elevation (m), same length as x_pos
    %
    % Definitions:
    %   EGL = P/(ρg) + V²/(2g) + z  [Total energy head]
    %   HGL = P/(ρg) + z             [Piezometric head]
    %   EGL = HGL + V²/(2g)          [Relationship]
    %
    % Reference:
    %   White, F.M. (2011). Fluid Mechanics (8th ed.). McGraw-Hill.
    
    % Extract parameters
    L = inputs.pipe.length;           % Total pipe length (m)
    z_in = inputs.system.z_inlet;     % Inlet elevation (m)
    z_out = inputs.system.z_outlet;   % Outlet elevation (m)
    P_in = inputs.system.P_inlet;     % Inlet pressure (Pa)
    rho = inputs.flow.rho;            % Density (kg/m³)
    g = 9.81;                         % Gravitational acceleration (m/s²)
    
    % Use profile positions (includes all fitting locations)
    x_pos = profile.x;
    h_loss_along = profile.h_total_cum;
    
    % Elevation profile (linear interpolation from inlet to outlet)
    elevation = z_in + (z_out - z_in) * (x_pos / L);
    
    % Velocity head (constant for constant diameter pipe)
    velocity_head = V^2 / (2*g);
    
    % Calculate inlet total head
    % H_in = P_in/(ρg) + V²/(2g) + z_in
    pressure_head_in = P_in / (rho * g);
    H_in_total = pressure_head_in + velocity_head + z_in;
    
    % Energy Grade Line (EGL)
    % EGL decreases according to actual loss profile (includes discrete drops at fittings)
    EGL = H_in_total - h_loss_along;
    
    % Hydraulic Grade Line (HGL)
    % HGL = EGL - V²/(2g)
    HGL = EGL - velocity_head;
    
    % Validation check
    % At outlet, HGL should equal outlet pressure head + elevation
    P_out_calculated = (HGL(end) - z_out) * rho * g;
    
    % Note: If there's a pump, EGL would have a jump at pump location
    % This version now shows discrete pressure drops at fitting locations
end
