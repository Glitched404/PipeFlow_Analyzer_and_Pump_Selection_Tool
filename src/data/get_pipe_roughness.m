function [roughness, name] = get_pipe_roughness(code)
    %% RETURN ROUGHNESS FOR MATERIAL CODE (A-F)
    % Returns absolute roughness for specified pipe material
    %
    % Input:
    %   code - Character (A-F, case insensitive)
    % Output:
    %   roughness - Absolute roughness (meters)
    %   name - Material name
    %
    % Reference:
    %   Moody, L.F. (1944). Friction Factors for Pipe Flow.
    %   Transactions of the ASME, 66(8), 671-684.
    
    code = upper(code);
    
    switch code
        case 'A'
            roughness = 0.046e-3;    % 0.046 mm
            name = 'Commercial Steel';
        case 'B'
            roughness = 0.0015e-3;   % 0.0015 mm
            name = 'PVC';
        case 'C'
            roughness = 0.26e-3;     % 0.26 mm
            name = 'Cast Iron';
        case 'D'
            roughness = 0.015e-3;    % 0.015 mm
            name = 'Stainless Steel';
        case 'E'
            roughness = 0.15e-3;     % 0.15 mm
            name = 'Galvanized Iron';
        case 'F'
            roughness = 0.0015e-3;   % 0.0015 mm
            name = 'Drawn Tubing';
        otherwise
            error('Invalid material code: %s (must be A-F)', code);
    end
end
