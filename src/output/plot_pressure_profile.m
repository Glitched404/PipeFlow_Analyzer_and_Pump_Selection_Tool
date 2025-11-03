function plot_pressure_profile(results, filename)
    %% PLOT PRESSURE PROFILE ALONG PIPE
    % Shows pressure variation along pipe length
    %
    % Input:
    %   results - Results structure with egl_hgl field
    %   filename - Output file path for PNG
    
    % Create figure
    fig = figure('Position', [100, 100, 1000, 700], 'Visible', 'off');
    hold on;
    grid on;
    
    % ═════════════════════════════════════════════════════════════════════
    % CALCULATE PRESSURE ALONG PIPE
    % ═════════════════════════════════════════════════════════════════════
    
    x = results.egl_hgl.x;           % Position along pipe (m)
    HGL = results.egl_hgl.HGL;       % Hydraulic grade line (m)
    elev = results.egl_hgl.elevation;  % Pipe centerline elevation (m)
    
    % Pressure head: P/(ρg) = HGL - z
    pressure_head = HGL - elev;
    
    % Convert to pressure (kPa)
    rho = results.inputs.flow.rho;
    g = 9.81;
    pressure_kPa = pressure_head * rho * g / 1000;
    
    % ═════════════════════════════════════════════════════════════════════
    % PLOT PRESSURE PROFILE
    % ═════════════════════════════════════════════════════════════════════
    
    % Main pressure curve
    plot(x, pressure_kPa, 'b-', 'LineWidth', 2.5, 'DisplayName', 'Pressure Profile');
    
    % Fill area under curve
    fill([x, fliplr(x)], [pressure_kPa, zeros(size(x))], ...
        'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    
    % ═════════════════════════════════════════════════════════════════════
    % MARK FITTING LOCATIONS WITH DISCRETE PRESSURE DROPS
    % ═════════════════════════════════════════════════════════════════════
    
    % Get fitting information
    if isfield(results.inputs, 'fittings') && ~isempty(results.inputs.fittings)
        % Find all duplicate x-positions (these indicate discrete drops)
        for i = 2:length(x)
            if abs(x(i) - x(i-1)) < 1e-6  % Same position = discrete drop
                % Draw vertical line for discrete drop
                plot([x(i), x(i)], [pressure_kPa(i-1), pressure_kPa(i)], 'r-', ...
                    'LineWidth', 3, 'HandleVisibility', 'off');
                
                % Mark the drop point
                plot(x(i), pressure_kPa(i), 'ro', 'MarkerSize', 8, ...
                    'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
            end
        end
        
        % Add legend entry for fittings
        plot(NaN, NaN, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', ...
            'DisplayName', 'Fitting Locations');
    end
    
    % ═════════════════════════════════════════════════════════════════════
    % MARK INLET AND OUTLET PRESSURES
    % ═════════════════════════════════════════════════════════════════════
    
    % Inlet
    P_inlet_kPa = results.inputs.system.P_inlet / 1000;
    plot(x(1), pressure_kPa(1), 'go', 'MarkerSize', 12, 'MarkerFaceColor', 'g', ...
        'LineWidth', 2, 'DisplayName', sprintf('Inlet (%.1f kPa)', pressure_kPa(1)));
    text(x(1), pressure_kPa(1) + 5, sprintf('Inlet\nP = %.1f kPa', pressure_kPa(1)), ...
        'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', ...
        'BackgroundColor', 'white', 'EdgeColor', 'green', 'LineWidth', 1);
    
    % Outlet
    plot(x(end), pressure_kPa(end), 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r', ...
        'LineWidth', 2, 'DisplayName', sprintf('Outlet (%.1f kPa)', pressure_kPa(end)));
    text(x(end), pressure_kPa(end) + 5, sprintf('Outlet\nP = %.1f kPa', pressure_kPa(end)), ...
        'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'right', ...
        'BackgroundColor', 'white', 'EdgeColor', 'red', 'LineWidth', 1);
    
    % ═════════════════════════════════════════════════════════════════════
    % SHOW PRESSURE DROP
    % ═════════════════════════════════════════════════════════════════════
    
    dP_total_kPa = results.total_losses.dP_total / 1000;
    
    % Draw arrow showing pressure drop
    arrow_y = max(pressure_kPa) * 0.8;
    annotation('doublearrow', [0.2, 0.8], [0.75, 0.75], 'LineWidth', 2, 'Color', 'r');
    annotation('textbox', [0.4, 0.77, 0.2, 0.05], ...
        'String', sprintf('ΔP_{total} = %.1f kPa', dP_total_kPa), ...
        'FontSize', 11, 'FontWeight', 'bold', 'Color', 'r', ...
        'HorizontalAlignment', 'center', 'EdgeColor', 'none', ...
        'BackgroundColor', 'white');
    
    % ═════════════════════════════════════════════════════════════════════
    % MARK ATMOSPHERIC PRESSURE LINE
    % ═════════════════════════════════════════════════════════════════════
    
    P_atm = 101.325;  % kPa
    plot([0, max(x)], [P_atm, P_atm], 'k--', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Atmospheric (%.1f kPa)', P_atm));
    
    % Check for negative pressure (cavitation risk)
    if min(pressure_kPa) < P_atm
        text(max(x)/2, P_atm + 5, '⚠ Pressure below atmospheric', ...
            'FontSize', 10, 'FontWeight', 'bold', 'Color', 'r', ...
            'HorizontalAlignment', 'center', 'BackgroundColor', 'yellow', ...
            'EdgeColor', 'red', 'LineWidth', 2);
    end
    
    % ═════════════════════════════════════════════════════════════════════
    % FORMATTING
    % ═════════════════════════════════════════════════════════════════════
    
    xlabel('Distance Along Pipe (m)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Pressure (kPa)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Pressure Profile Along Pipe', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Axis limits
    xlim([0, max(x)]);
    ylim([min(0, min(pressure_kPa) - 10), max(pressure_kPa) + 20]);
    
    % Legend
    legend('Location', 'best', 'FontSize', 9);
    
    % Grid
    grid on;
    set(gca, 'GridLineStyle', '-', 'GridAlpha', 0.3);
    
    % Add info box
    info_text = sprintf(['Pressure Loss Breakdown:\n\n' ...
                        'Friction Loss:\n' ...
                        '  ΔP_f = %.1f kPa (%.0f%%)\n\n' ...
                        'Minor Losses:\n' ...
                        '  ΔP_m = %.1f kPa (%.0f%%)\n\n' ...
                        'Total Loss:\n' ...
                        '  ΔP_total = %.1f kPa\n\n' ...
                        'Pressure Gradient:\n' ...
                        '  %.2f kPa/m'], ...
                        results.friction.dP_f/1000, ...
                        100*results.friction.dP_f/results.total_losses.dP_total, ...
                        results.minor_losses.dP_m/1000, ...
                        100*results.minor_losses.dP_m/results.total_losses.dP_total, ...
                        dP_total_kPa, ...
                        dP_total_kPa / results.inputs.pipe.length);
    
    annotation('textbox', [0.15, 0.15, 0.25, 0.30], ...
        'String', info_text, ...
        'FontSize', 9, 'BackgroundColor', 'white', 'EdgeColor', 'black', ...
        'LineWidth', 1.5, 'FitBoxToText', 'on');
    
    % Add material and flow info
    material_text = sprintf(['Pipe Specifications:\n' ...
                            'Material: %s\n' ...
                            'Diameter: %.0f mm\n' ...
                            'Length: %.1f m\n' ...
                            'Roughness: %.4f mm\n\n' ...
                            'Flow Conditions:\n' ...
                            'Q = %.1f L/s\n' ...
                            'V = %.2f m/s\n' ...
                            'Re = %.0f'], ...
                            results.inputs.pipe.material_name, ...
                            results.inputs.pipe.diameter*1000, ...
                            results.inputs.pipe.length, ...
                            results.inputs.pipe.roughness*1e6, ...
                            results.flow.Q*1000, ...
                            results.flow.V, ...
                            results.flow.Re);
    
    annotation('textbox', [0.68, 0.15, 0.25, 0.30], ...
        'String', material_text, ...
        'FontSize', 9, 'BackgroundColor', 'white', 'EdgeColor', 'black', ...
        'LineWidth', 1.5, 'FitBoxToText', 'on');
    
    hold off;
    
    % ═════════════════════════════════════════════════════════════════════
    % SAVE FIGURE
    % ═════════════════════════════════════════════════════════════════════
    
    saveas(fig, filename);
    close(fig);
end
