function pipe_specs = get_pipe_specs()
    %% GET PIPE SPECIFICATIONS FROM USER
    % Interactive function to collect pipe parameters
    %
    % Output:
    %   pipe_specs - Structure with fields:
    %       .diameter (m) - Inner diameter
    %       .length (m) - Total pipe length
    %       .material (string) - Material code (lowercase)
    %       .material_name (string) - Display name
    %       .roughness (m) - Absolute roughness
    
    % Diameter input
    prompt = 'Enter pipe inner diameter (mm) [default: 100]: ';
    D_mm = input(prompt);
    if isempty(D_mm), D_mm = 100; end
    
    % Validation
    if D_mm <= 0 || D_mm > 5000
        fprintf('⚠ Warning: Unusual diameter. Using 100 mm.\n');
        D_mm = 100;
    end
    
    % Length input
    prompt = 'Enter total pipe length (m) [default: 50]: ';
    L = input(prompt);
    if isempty(L), L = 50; end
    
    % Validation
    if L <= 0 || L > 10000
        fprintf('⚠ Warning: Unusual length. Using 50 m.\n');
        L = 50;
    end
    
    % Material selection
    fprintf('\nSelect pipe material:\n');
    fprintf('  [A] Commercial Steel (ε = 0.046 mm)\n');
    fprintf('  [B] PVC (ε = 0.0015 mm)\n');
    fprintf('  [C] Cast Iron (ε = 0.26 mm)\n');
    fprintf('  [D] Stainless Steel (ε = 0.015 mm)\n');
    fprintf('  [E] Galvanized Iron (ε = 0.15 mm)\n');
    fprintf('  [F] Drawn Tubing (ε = 0.0015 mm)\n\n');
    
    material_code = input('Your choice [A]: ', 's');
    if isempty(material_code), material_code = 'A'; end
    
    try
        [roughness, material_name] = get_pipe_roughness(material_code);
        fprintf('✓ Selected: %s (ε = %.4f mm)\n', material_name, roughness*1e6);
    catch
        fprintf('⚠ Invalid code. Using Commercial Steel.\n');
        [roughness, material_name] = get_pipe_roughness('A');
        material_code = 'A';
    end
    
    % Store in structure
    pipe_specs = struct();
    pipe_specs.diameter = D_mm / 1000;  % Convert to meters
    pipe_specs.length = L;
    pipe_specs.material = lower(material_code);
    pipe_specs.material_name = material_name;
    pipe_specs.roughness = roughness;
end
