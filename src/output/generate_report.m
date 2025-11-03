function generate_report(inputs, results, filename)
    %% GENERATE TEXT REPORT
    % Creates professional text report of analysis results
    %
    % Input:
    %   inputs - Input parameters structure
    %   results - Calculation results structure
    %   filename - Output file path
    
    % Open file for writing
    fid = fopen(filename, 'w');
    if fid == -1
        error('Cannot create report file: %s', filename);
    end
    
    % Helper function to write centered text
    function write_centered(text, width)
        padding = floor((width - length(text)) / 2);
        fprintf(fid, '%s%s\n', repmat(' ', 1, padding), text);
    end
    
    % ═════════════════════════════════════════════════════════════════════
    % HEADER
    % ═════════════════════════════════════════════════════════════════════
    
    fprintf(fid, '╔════════════════════════════════════════════════════════════════╗\n');
    fprintf(fid, '║            PIPE FLOW ANALYSIS REPORT                           ║\n');
    fprintf(fid, '╚════════════════════════════════════════════════════════════════╝\n\n');
    
    fprintf(fid, 'Generated: %s\n', datestr(inputs.timestamp, 'dd-mmm-yyyy HH:MM:SS'));
    fprintf(fid, 'Analysis Tool: Pipe Flow Analyzer v1.0\n\n');
    
    % ═════════════════════════════════════════════════════════════════════
    % SYSTEM INPUTS
    % ═════════════════════════════════════════════════════════════════════
    
    fprintf(fid, '════════════════════════════════════════════════════════════════\n');
    fprintf(fid, 'SYSTEM INPUTS\n');
    fprintf(fid, '════════════════════════════════════════════════════════════════\n\n');
    
    % Pipe specifications
    fprintf(fid, 'PIPE SPECIFICATIONS:\n');
    fprintf(fid, '  Material: %s\n', inputs.pipe.material_name);
    fprintf(fid, '  Diameter: %.1f mm (DN%.0f)\n', ...
        inputs.pipe.diameter*1000, inputs.pipe.diameter*1000);
    fprintf(fid, '  Length: %.1f m\n', inputs.pipe.length);
    fprintf(fid, '  Roughness: %.4f mm\n\n', inputs.pipe.roughness*1e6);
    
    % Fluid properties
    fprintf(fid, 'FLUID PROPERTIES:\n');
    fprintf(fid, '  Fluid: Water\n');
    fprintf(fid, '  Temperature: %.1f °C\n', inputs.flow.temperature);
    fprintf(fid, '  Density: %.1f kg/m³\n', inputs.flow.rho);
    fprintf(fid, '  Viscosity: %.3e Pa·s\n\n', inputs.flow.mu);
    
    % Flow conditions
    fprintf(fid, 'FLOW CONDITIONS:\n');
    fprintf(fid, '  Flow rate: %.2f L/s (%.4f m³/s)\n', ...
        inputs.flow.Q*1000, inputs.flow.Q);
    fprintf(fid, '  Velocity: %.3f m/s\n', results.flow.V);
    fprintf(fid, '  Input method: %s\n\n', inputs.flow.method);
    
    % Fittings
    fprintf(fid, 'FITTINGS & COMPONENTS:\n');
    if isempty(inputs.fittings)
        fprintf(fid, '  None specified\n\n');
    else
        for i = 1:length(inputs.fittings)
            fprintf(fid, '  %s at %.2f m (K = %.2f)\n', ...
                inputs.fittings(i).name, ...
                inputs.fittings(i).position, ...
                inputs.fittings(i).K);
        end
        fprintf(fid, '  Total K-factor: %.2f\n\n', results.minor_losses.K_total);
    end
    
    % System configuration
    fprintf(fid, 'SYSTEM CONFIGURATION:\n');
    fprintf(fid, '  Inlet elevation: %.2f m\n', inputs.system.z_inlet);
    fprintf(fid, '  Outlet elevation: %.2f m\n', inputs.system.z_outlet);
    fprintf(fid, '  Static head: %.2f m\n', ...
        inputs.system.z_outlet - inputs.system.z_inlet);
    fprintf(fid, '  Inlet pressure: %.2f kPa\n', inputs.system.P_inlet/1000);
    fprintf(fid, '  Outlet pressure: %.2f kPa\n\n', inputs.system.P_outlet/1000);
    
    % ═════════════════════════════════════════════════════════════════════
    % FLOW CHARACTERISTICS
    % ═════════════════════════════════════════════════════════════════════
    
    fprintf(fid, '════════════════════════════════════════════════════════════════\n');
    fprintf(fid, 'FLOW CHARACTERISTICS\n');
    fprintf(fid, '════════════════════════════════════════════════════════════════\n\n');
    
    fprintf(fid, '  Reynolds number: %.0f\n', results.flow.Re);
    fprintf(fid, '  Flow regime: %s\n', results.flow.regime);
    fprintf(fid, '  Relative roughness (ε/D): %.6f\n', results.moody.eps_D);
    fprintf(fid, '  Friction factor (f): %.4f\n\n', results.friction.f);
    
    % ═════════════════════════════════════════════════════════════════════
    % PRESSURE LOSSES
    % ═════════════════════════════════════════════════════════════════════
    
    fprintf(fid, '════════════════════════════════════════════════════════════════\n');
    fprintf(fid, 'PRESSURE LOSSES\n');
    fprintf(fid, '════════════════════════════════════════════════════════════════\n\n');
    
    % Major losses
    fprintf(fid, 'MAJOR LOSSES (Friction):\n');
    fprintf(fid, '  Head loss: %.3f m\n', results.friction.h_f);
    fprintf(fid, '  Pressure drop: %.2f kPa\n', results.friction.dP_f/1000);
    fprintf(fid, '  Percentage of total: %.1f%%\n\n', ...
        100*results.friction.h_f/results.total_losses.h_L);
    
    % Minor losses
    fprintf(fid, 'MINOR LOSSES (Fittings):\n');
    fprintf(fid, '  Head loss: %.3f m\n', results.minor_losses.h_m);
    fprintf(fid, '  Pressure drop: %.2f kPa\n', results.minor_losses.dP_m/1000);
    fprintf(fid, '  Percentage of total: %.1f%%\n\n', ...
        100*results.minor_losses.h_m/results.total_losses.h_L);
    
    % Total losses
    fprintf(fid, 'TOTAL LOSSES:\n');
    fprintf(fid, '  Head loss: %.3f m\n', results.total_losses.h_L);
    fprintf(fid, '  Pressure drop: %.2f kPa\n\n', results.total_losses.dP_total/1000);
    
    % ═════════════════════════════════════════════════════════════════════
    % PUMP SELECTION
    % ═════════════════════════════════════════════════════════════════════
    
    fprintf(fid, '════════════════════════════════════════════════════════════════\n');
    fprintf(fid, 'PUMP SELECTION\n');
    fprintf(fid, '════════════════════════════════════════════════════════════════\n\n');
    
    fprintf(fid, 'SELECTED PUMP: %s\n', results.pump_selection.name);
    fprintf(fid, '  Type: %s\n', results.pump_selection.type);
    fprintf(fid, '  Operating point:\n');
    fprintf(fid, '    Flow: %.2f L/s (%.4f m³/s)\n', ...
        results.pump_selection.Q_operating*1000, results.pump_selection.Q_operating);
    fprintf(fid, '    Head: %.2f m\n', results.pump_selection.H_operating);
    fprintf(fid, '    Efficiency: %.1f%%\n\n', results.pump_selection.efficiency*100);
    
    % ═════════════════════════════════════════════════════════════════════
    % POWER REQUIREMENTS
    % ═════════════════════════════════════════════════════════════════════
    
    fprintf(fid, '════════════════════════════════════════════════════════════════\n');
    fprintf(fid, 'POWER REQUIREMENTS\n');
    fprintf(fid, '════════════════════════════════════════════════════════════════\n\n');
    
    fprintf(fid, '  Hydraulic power: %.2f kW (%.2f HP)\n', ...
        results.power.hydraulic, results.power.hydraulic*1.341);
    fprintf(fid, '  Shaft power: %.2f kW (%.2f HP)\n', ...
        results.power.shaft, results.power.shaft*1.341);
    fprintf(fid, '  Motor power: %.2f kW (%.2f HP)\n', ...
        results.power.motor, results.power.motor*1.341);
    fprintf(fid, '  (Motor includes 15%% safety margin)\n\n');
    
    % ═════════════════════════════════════════════════════════════════════
    % SYSTEM CURVE
    % ═════════════════════════════════════════════════════════════════════
    
    fprintf(fid, '════════════════════════════════════════════════════════════════\n');
    fprintf(fid, 'SYSTEM CURVE\n');
    fprintf(fid, '════════════════════════════════════════════════════════════════\n\n');
    
    fprintf(fid, '  Equation: H_sys(Q) = H_static + K_sys × Q²\n');
    fprintf(fid, '  Static head: %.2f m\n', results.system_curve.H_static);
    fprintf(fid, '  System coefficient: %.2f (m/(m³/s)²)\n', ...
        results.system_curve.K_sys);
    fprintf(fid, '  At design flow (%.2f L/s): H = %.2f m\n\n', ...
        inputs.flow.Q*1000, ...
        results.system_curve.H_static + results.system_curve.K_sys * inputs.flow.Q^2);
    
    % ═════════════════════════════════════════════════════════════════════
    % SUMMARY & RECOMMENDATIONS
    % ═════════════════════════════════════════════════════════════════════
    
    fprintf(fid, '════════════════════════════════════════════════════════════════\n');
    fprintf(fid, 'SUMMARY & RECOMMENDATIONS\n');
    fprintf(fid, '════════════════════════════════════════════════════════════════\n\n');
    
    fprintf(fid, 'SYSTEM SUMMARY:\n');
    fprintf(fid, '  • Flow regime is %s (Re = %.0f)\n', ...
        lower(results.flow.regime), results.flow.Re);
    fprintf(fid, '  • Total head loss is %.2f m (%.1f kPa)\n', ...
        results.total_losses.h_L, results.total_losses.dP_total/1000);
    fprintf(fid, '  • Friction losses represent %.0f%% of total\n', ...
        100*results.friction.h_f/results.total_losses.h_L);
    fprintf(fid, '  • Selected pump operates at %.0f%% efficiency\n\n', ...
        results.pump_selection.efficiency*100);
    
    fprintf(fid, 'RECOMMENDATIONS:\n');
    
    % Check efficiency
    if results.pump_selection.efficiency < 0.65
        fprintf(fid, '  ⚠ Pump efficiency is below 65%%. Consider alternative pump.\n');
    else
        fprintf(fid, '  ✓ Pump efficiency is acceptable (>65%%).\n');
    end
    
    % Check velocity
    if results.flow.V < 0.5
        fprintf(fid, '  ⚠ Velocity is very low (<0.5 m/s). Risk of sedimentation.\n');
    elseif results.flow.V > 3.0
        fprintf(fid, '  ⚠ Velocity is high (>3.0 m/s). May cause erosion/noise.\n');
    else
        fprintf(fid, '  ✓ Velocity is within acceptable range (0.5-3.0 m/s).\n');
    end
    
    % Check Reynolds number
    if strcmp(results.flow.regime, 'Laminar')
        fprintf(fid, '  ⚠ Laminar flow detected. Consider increasing flow rate.\n');
    elseif strcmp(results.flow.regime, 'Transitional')
        fprintf(fid, '  ⚠ Transitional flow is unstable. Adjust flow if possible.\n');
    else
        fprintf(fid, '  ✓ Flow is fully turbulent (stable operation).\n');
    end
    
    fprintf(fid, '\n');
    
    % ═════════════════════════════════════════════════════════════════════
    % FOOTER
    % ═════════════════════════════════════════════════════════════════════
    
    fprintf(fid, '════════════════════════════════════════════════════════════════\n');
    fprintf(fid, 'END OF REPORT\n');
    fprintf(fid, '════════════════════════════════════════════════════════════════\n\n');
    
    fprintf(fid, 'Generated by: Pipe Flow Analyzer\n');
    fprintf(fid, 'Report file: %s\n', filename);
    fprintf(fid, 'Timestamp: %s\n', datestr(now, 'dd-mmm-yyyy HH:MM:SS'));
    
    % Close file
    fclose(fid);
end
