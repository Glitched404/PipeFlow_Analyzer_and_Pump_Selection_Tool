function [K, name] = get_fitting_K(code)
    %% RETURN K-FACTOR FOR FITTING CODE (A-N)
    % Returns the minor loss coefficient for specified fitting type
    %
    % Input:
    %   code - Character (A-N, case insensitive)
    % Output:
    %   K - Minor loss coefficient (dimensionless)
    %   name - Descriptive name of fitting
    %
    % Reference:
    %   Crane Co. (1991). Flow of Fluids Through Valves, Fittings, and Pipe.
    %   Technical Paper 410.
    
    code = upper(code);
    
    switch code
        case 'A'
            K = 0.9;
            name = '90° Standard Elbow';
        case 'B'
            K = 0.6;
            name = '90° Long Radius Elbow';
        case 'C'
            K = 0.4;
            name = '45° Elbow';
        case 'D'
            K = 0.6;
            name = 'Tee - Through Flow';
        case 'E'
            K = 1.8;
            name = 'Tee - Branch Flow';
        case 'F'
            K = 0.2;
            name = 'Gate Valve (Open)';
        case 'G'
            K = 10.0;
            name = 'Globe Valve (Open)';
        case 'H'
            K = 0.05;
            name = 'Ball Valve (Open)';
        case 'I'
            K = 2.0;
            name = 'Check Valve';
        case 'J'
            K = 1.0;
            name = 'Sudden Expansion';
        case 'K'
            K = 0.5;
            name = 'Sudden Contraction';
        case 'L'
            K = 0.5;
            name = 'Sharp Entrance';
        case 'M'
            K = 0.04;
            name = 'Rounded Entrance';
        case 'N'
            K = 1.0;
            name = 'Exit';
        otherwise
            error('Invalid fitting code: %s (must be A-N)', code);
    end
end
