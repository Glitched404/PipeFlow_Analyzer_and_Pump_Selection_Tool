function system_config = get_system_config()
    %% GET SYSTEM CONFIGURATION FROM USER
    % Interactive function to collect elevation and pressure boundary conditions
    %
    % Output:
    %   system_config - Structure with fields:
    %       .z_inlet (m) - Inlet elevation
    %       .z_outlet (m) - Outlet elevation
    %       .P_inlet (Pa) - Inlet pressure
    %       .P_outlet (Pa) - Outlet pressure
    
    % Inlet elevation
    prompt = 'Enter inlet elevation (m) [default: 0]: ';
    z_in = input(prompt);
    if isempty(z_in), z_in = 0; end
    
    % Outlet elevation
    prompt = 'Enter outlet elevation (m) [default: 0]: ';
    z_out = input(prompt);
    if isempty(z_out), z_out = 0; end
    
    % Inlet pressure
    prompt = 'Enter inlet pressure (kPa) [default: 101.325]: ';
    P_in_kPa = input(prompt);
    if isempty(P_in_kPa), P_in_kPa = 101.325; end
    
    % Outlet pressure
    prompt = 'Enter outlet pressure (kPa) [default: 101.325]: ';
    P_out_kPa = input(prompt);
    if isempty(P_out_kPa), P_out_kPa = 101.325; end
    
    % Display static head
    static_head = z_out - z_in;
    fprintf('✓ Static head: %.1f m', static_head);
    if static_head > 0
        fprintf(' (pumping upward)\n');
    elseif static_head < 0
        fprintf(' (flowing downward)\n');
    else
        fprintf(' (horizontal)\n');
    end
    
    % Store in structure
    system_config = struct();
    system_config.z_inlet = z_in;
    system_config.z_outlet = z_out;
    system_config.P_inlet = P_in_kPa * 1000;   % Convert to Pa
    system_config.P_outlet = P_out_kPa * 1000; % Convert to Pa
end
