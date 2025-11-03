function [rho, mu, Cp, k] = get_water_properties_coolprop(T_celsius)
    %% GET WATER PROPERTIES AT GIVEN TEMPERATURE
    % Uses CoolProp if available, otherwise fallback to lookup table
    %
    % Input:
    %   T_celsius - Temperature in degrees Celsius
    % Output:
    %   rho - Density (kg/m³)
    %   mu - Dynamic viscosity (Pa·s)
    %   Cp - Specific heat capacity (J/kg·K)
    %   k - Thermal conductivity (W/m·K)
    %
    % Reference:
    %   NIST Standard Reference Data (https://www.nist.gov/)
    %   CoolProp library (http://www.coolprop.org/)
    
    try
        % Try using CoolProp (Python interface)
        T_kelvin = T_celsius + 273.15;
        P = 101325;  % Atmospheric pressure (Pa)
        
        % Call CoolProp via Python
        rho = double(py.CoolProp.CoolProp.PropsSI('D', 'T', T_kelvin, 'P', P, 'Water'));
        mu = double(py.CoolProp.CoolProp.PropsSI('V', 'T', T_kelvin, 'P', P, 'Water'));
        Cp = double(py.CoolProp.CoolProp.PropsSI('C', 'T', T_kelvin, 'P', P, 'Water'));
        k = double(py.CoolProp.CoolProp.PropsSI('L', 'T', T_kelvin, 'P', P, 'Water'));
        
    catch
        % Fallback to lookup table if CoolProp not available
        [rho, mu, Cp, k] = water_properties_table(T_celsius);
    end
end

function [rho, mu, Cp, k] = water_properties_table(T_celsius)
    %% WATER PROPERTIES LOOKUP TABLE
    % Fallback method if CoolProp is not installed
    % Data at atmospheric pressure (101.325 kPa)
    %
    % Input:
    %   T_celsius - Temperature in degrees Celsius
    % Output:
    %   rho - Density (kg/m³)
    %   mu - Dynamic viscosity (Pa·s)
    %   Cp - Specific heat capacity (J/kg·K)
    %   k - Thermal conductivity (W/m·K)
    %
    % Reference:
    %   White, F.M. (2011). Fluid Mechanics (8th ed.). McGraw-Hill.
    %   ASHRAE Handbook - Fundamentals (2021)
    
    % Lookup table: [T(°C), rho(kg/m³), mu(Pa·s), Cp(J/kg·K), k(W/m·K)]
    data = [
        0,    999.8,  1.787e-3,  4217,  0.561;
        5,    999.9,  1.519e-3,  4205,  0.571;
        10,   999.7,  1.307e-3,  4195,  0.580;
        15,   999.1,  1.139e-3,  4186,  0.589;
        20,   998.2,  1.002e-3,  4182,  0.598;
        25,   997.0,  8.90e-4,   4179,  0.607;
        30,   995.7,  7.98e-4,   4178,  0.615;
        35,   994.0,  7.20e-4,   4178,  0.623;
        40,   992.2,  6.53e-4,   4179,  0.630;
        45,   990.2,  5.94e-4,   4180,  0.637;
        50,   988.0,  5.47e-4,   4181,  0.644;
        55,   985.7,  5.04e-4,   4183,  0.651;
        60,   983.2,  4.67e-4,   4185,  0.659;
        65,   980.5,  4.36e-4,   4186,  0.666;
        70,   977.8,  4.04e-4,   4187,  0.673;
        75,   974.8,  3.77e-4,   4189,  0.680;
        80,   971.8,  3.55e-4,   4191,  0.688;
        85,   968.6,  3.34e-4,   4193,  0.695;
        90,   965.3,  3.15e-4,   4196,  0.702;
        95,   961.9,  2.98e-4,   4197,  0.709;
        100,  958.4,  2.82e-4,   4199,  0.716
    ];
    
    % Interpolate properties at requested temperature
    % Use linear interpolation with extrapolation for out-of-range values
    rho = interp1(data(:,1), data(:,2), T_celsius, 'linear', 'extrap');
    mu = interp1(data(:,1), data(:,3), T_celsius, 'linear', 'extrap');
    Cp = interp1(data(:,1), data(:,4), T_celsius, 'linear', 'extrap');
    k = interp1(data(:,1), data(:,5), T_celsius, 'linear', 'extrap');
    
    % Ensure positive values (in case of extrapolation issues)
    rho = max(rho, 900);     % kg/m³
    mu = max(mu, 1e-4);      % Pa·s
    Cp = max(Cp, 4000);      % J/kg·K
    k = max(k, 0.5);         % W/m·K
end
