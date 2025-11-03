function [f, regime] = get_f_from_moody_chart(Re, eps_D)
    %% CALCULATE FRICTION FACTOR FROM MOODY CHART METHOD
    % Implements the Colebrook-White equation which underlies the Moody chart
    %
    % Input:
    %   Re - Reynolds number (dimensionless)
    %   eps_D - Relative roughness (ε/D, dimensionless)
    % Output:
    %   f - Darcy friction factor (dimensionless)
    %   regime - Flow regime string ('Laminar', 'Transitional', 'Turbulent')
    %
    % Formulas:
    %   Laminar (Re < 2300):
    %       f = 64 / Re
    %   Turbulent (Re > 4000):
    %       1/√f = -2 log₁₀(ε/D/3.7 + 2.51/(Re√f))  [Colebrook-White]
    %   Transitional (2300 ≤ Re ≤ 4000):
    %       Linear interpolation between laminar and turbulent
    %
    % Reference:
    %   Colebrook, C.F. (1939). "Turbulent Flow in Pipes, with Particular
    %   Reference to the Transition Region." Journal of ICE, 11(4), 133-156.
    
    % Classify flow regime based on Reynolds number
    if Re < 2300
        % LAMINAR FLOW
        % Exact solution: f = 64/Re (Hagen-Poiseuille)
        f = 64 / Re;
        regime = 'Laminar';
        
    elseif Re < 4000
        % TRANSITIONAL FLOW
        % Interpolate between laminar and turbulent values
        % This region is inherently unstable and difficult to predict
        
        % Get friction factors at boundaries
        f_lam = 64 / 2300;                        % Laminar at Re=2300
        f_turb = solve_colebrook_white(4000, eps_D);  % Turbulent at Re=4000
        
        % Linear interpolation
        weight = (Re - 2300) / (4000 - 2300);
        f = f_lam + (f_turb - f_lam) * weight;
        regime = 'Transitional';
        
    else
        % TURBULENT FLOW
        % Solve Colebrook-White equation iteratively
        f = solve_colebrook_white(Re, eps_D);
        regime = 'Turbulent';
    end
    
    % Ensure friction factor is physically reasonable (suppress warning for plotting)
    % Only warn for actual calculations, not for Moody diagram generation
    if (f < 0.008 || f > 0.10) && Re < 1e7
        % Only warn for realistic flow conditions
        if Re > 100 && Re < 1e6
            warning('Friction factor f=%.4f is outside typical range [0.008, 0.10]', f);
        end
    end
end

function f = solve_colebrook_white(Re, eps_D)
    %% SOLVE COLEBROOK-WHITE EQUATION USING NEWTON-RAPHSON
    % Iteratively solves the implicit Colebrook-White equation
    %
    % Equation: 1/√f = -2 log₁₀(ε/D/3.7 + 2.51/(Re√f))
    %
    % Input:
    %   Re - Reynolds number (dimensionless)
    %   eps_D - Relative roughness (ε/D, dimensionless)
    % Output:
    %   f - Darcy friction factor (dimensionless)
    %
    % Method:
    %   Newton-Raphson iteration with Swamee-Jain initial guess
    %
    % Reference:
    %   Swamee, P.K. & Jain, A.K. (1976). "Explicit Equations for Pipe-Flow
    %   Problems." Journal of Hydraulics Division, ASCE, 102(5), 657-664.
    
    % Initial guess using Swamee-Jain approximation
    % This provides a good starting point close to the true solution
    if eps_D == 0
        % Smooth pipe approximation
        f = 0.25 / (log10(5.74/Re^0.9))^2;
    else
        % General case
        f = 0.25 / (log10(eps_D/3.7 + 5.74/Re^0.9))^2;
    end
    
    % Newton-Raphson iteration
    % Converges very quickly (typically 3-5 iterations)
    max_iter = 20;
    tolerance = 1e-8;
    
    for iter = 1:max_iter
        % Current friction factor and its square root
        f_sqrt = sqrt(f);
        
        % Colebrook-White equation rearranged as F(f) = 0
        % F(f) = 1/√f + 2 log₁₀(ε/D/3.7 + 2.51/(Re√f))
        term = eps_D/3.7 + 2.51/(Re*f_sqrt);
        F = 1/f_sqrt + 2*log10(term);
        
        % Derivative dF/df
        % dF/df = -1/(2f^(3/2)) - (2/(ln(10)*term)) * (-2.51/(2*Re*f^(3/2)))
        dF = -0.5 * f^(-1.5) - (2.0/(log(10)*term)) * (-1.255/(Re*f^1.5));
        
        % Newton-Raphson update
        f_new = f - F/dF;
        
        % Check convergence
        if abs(f_new - f) < tolerance
            f = f_new;
            return;
        end
        
        % Update for next iteration
        f = f_new;
        
        % Safeguard against non-physical values
        if f < 0.008
            f = 0.008;
        elseif f > 0.10
            f = 0.10;
        end
    end
    
    % If we reach here, iteration didn't converge (rare)
    % Suppress warning for extreme conditions during plotting
    if Re > 100 && Re < 1e6
        warning('Colebrook-White iteration did not converge after %d iterations', max_iter);
    end
end
