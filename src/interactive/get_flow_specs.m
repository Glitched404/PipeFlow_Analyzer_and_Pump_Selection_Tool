function flow_specs = get_flow_specs(pipe_specs)
    %% GET FLOW SPECIFICATIONS FROM USER
    % Interactive function to collect flow parameters
    %
    % Input:
    %   pipe_specs - Pipe specifications structure (for area calculation)
    % Output:
    %   flow_specs - Structure with fields:
    %       .method (string) - 'flow_rate', 'velocity', or 'pitot'
    %       .Q (m³/s) - Volumetric flow rate
    %       .V (m/s) - Velocity
    %       .temperature (°C) - Fluid temperature
    %       .rho (kg/m³) - Density
    %       .mu (Pa·s) - Dynamic viscosity
    
    % Temperature input
    prompt = 'Enter fluid temperature (°C) [default: 20]: ';
    T = input(prompt);
    if isempty(T), T = 20; end
    
    % Validation
    if T < 0 || T > 100
        fprintf('⚠ Warning: Temperature outside 0-100°C range. Using 20°C.\n');
        T = 20;
    end
    
    % Get fluid properties
    [rho, mu, ~, ~] = get_water_properties_coolprop(T);
    
    fprintf('\nFlow input method:\n');
    fprintf('  [1] Flow rate (L/s)\n');
    fprintf('  [2] Velocity (m/s)\n');
    fprintf('  [3] Pitot tube reading (mm H2O)\n\n');
    
    method = input('Your choice [1]: ', 's');
    if isempty(method), method = '1'; end
    
    % Calculate pipe area
    D = pipe_specs.diameter;
    A = pi * D^2 / 4;
    
    % Get flow based on selected method
    switch method
        case '1'
            % Flow rate input
            prompt = 'Enter flow rate (L/s) [default: 10]: ';
            Q_Ls = input(prompt);
            if isempty(Q_Ls), Q_Ls = 10; end
            
            % Validation
            if Q_Ls <= 0 || Q_Ls > 10000
                fprintf('⚠ Invalid flow rate. Using 10 L/s.\n');
                Q_Ls = 10;
            end
            
            Q = Q_Ls / 1000;  % Convert to m³/s
            V = Q / A;
            
            fprintf('✓ Flow rate: %.1f L/s (%.2f m/s)\n', Q_Ls, V);
            input_method = 'flow_rate';
            
        case '2'
            % Velocity input
            prompt = 'Enter velocity (m/s) [default: 2.0]: ';
            V = input(prompt);
            if isempty(V), V = 2.0; end
            
            % Validation
            if V <= 0 || V > 20
                fprintf('⚠ Invalid velocity. Using 2.0 m/s.\n');
                V = 2.0;
            end
            
            Q = V * A;
            Q_Ls = Q * 1000;
            
            fprintf('✓ Velocity: %.2f m/s (%.1f L/s)\n', V, Q_Ls);
            input_method = 'velocity';
            
        case '3'
            % Pitot tube reading
            prompt = 'Enter manometer reading (mm H2O) [default: 50]: ';
            h_mm = input(prompt);
            if isempty(h_mm), h_mm = 50; end
            
            % Validation
            if h_mm <= 0 || h_mm > 10000
                fprintf('⚠ Invalid reading. Using 50 mm H2O.\n');
                h_mm = 50;
            end
            
            % Calculate velocity from pitot tube (assuming Cv = 1.0)
            dP = rho * 9.81 * (h_mm / 1000);
            V = sqrt(2 * dP / rho);
            Q = V * A;
            Q_Ls = Q * 1000;
            
            fprintf('✓ Pitot reading: %.0f mm H2O → V = %.2f m/s (%.1f L/s)\n', ...
                h_mm, V, Q_Ls);
            input_method = 'pitot';
        
        otherwise
            % Default to 10 L/s
            fprintf('⚠ Invalid choice. Using default: 10 L/s\n');
            Q = 0.010;  % 10 L/s in m³/s
            V = Q / A;
            Q_Ls = Q * 1000;
            input_method = 'flow_rate';
    end
    
    % Store in structure
    flow_specs = struct();
    flow_specs.method = input_method;
    flow_specs.Q = Q;
    flow_specs.V = V;
    flow_specs.temperature = T;
    flow_specs.rho = rho;
    flow_specs.mu = mu;
end
