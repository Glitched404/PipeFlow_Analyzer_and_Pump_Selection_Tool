function plot_system_pump_curves(results, filename)
    %% PLOT SYSTEM CURVE AND PUMP CURVE WITH OPERATING POINT
    % Shows intersection of system curve and selected pump curve
    %
    % Input:
    %   results - Results structure with system_curve and pump_selection
    %   filename - Output file path for PNG
    
    % Create figure
    fig = figure('Position', [100, 100, 1000, 700], 'Visible', 'off');
    hold on;
    grid on;
    
    % ═════════════════════════════════════════════════════════════════════
    % PLOT SYSTEM CURVE
    % ═════════════════════════════════════════════════════════════════════
    
    Q_sys = results.system_curve.Q_range * 1000;  % Convert to L/s
    H_sys = results.system_curve.H_range;
    
    % Ensure column vectors
    Q_sys = Q_sys(:);
    H_sys = H_sys(:);
    
    plot(Q_sys, H_sys, 'b-', 'LineWidth', 2.5, 'DisplayName', 'System Curve');
    
    % ═════════════════════════════════════════════════════════════════════
    % PLOT PUMP CURVE
    % ═════════════════════════════════════════════════════════════════════
    
    Q_pump = results.pump_selection.pump_curve_Q;  % Already in L/s
    H_pump = results.pump_selection.pump_curve_H;
    
    % Ensure column vectors
    Q_pump = Q_pump(:);
    H_pump = H_pump(:);
    
    plot(Q_pump, H_pump, 'r-', 'LineWidth', 2.5, ...
        'DisplayName', sprintf('Pump: %s', results.pump_selection.name));
    
    % ═════════════════════════════════════════════════════════════════════
    % PLOT PUMP EFFICIENCY CURVE (SECONDARY AXIS)
    % ═════════════════════════════════════════════════════════════════════
    
    yyaxis right;
    eff_pump = results.pump_selection.pump_curve_eff * 100;  % Convert to %
    plot(Q_pump, eff_pump, 'g--', 'LineWidth', 2, 'DisplayName', 'Pump Efficiency');
    ylabel('Efficiency (%)', 'FontSize', 12, 'FontWeight', 'bold');
    ylim([0, 100]);
    set(gca, 'YColor', 'g');
    
    % ═════════════════════════════════════════════════════════════════════
    % MARK OPERATING POINT
    % ═════════════════════════════════════════════════════════════════════
    
    yyaxis left;  % Back to left axis for operating point
    
    Q_op = results.pump_selection.Q_operating * 1000;  % Convert to L/s
    H_op = results.pump_selection.H_operating;
    eff_op = results.pump_selection.efficiency * 100;
    
    % Plot operating point
    plot(Q_op, H_op, 'ko', 'MarkerSize', 14, 'MarkerFaceColor', 'yellow', ...
        'LineWidth', 2, 'DisplayName', 'Operating Point');
    
    % Add text label
    text(Q_op * 1.05, H_op * 1.05, ...
        sprintf('Operating Point\nQ = %.1f L/s\nH = %.1f m\nη = %.1f%%', ...
                Q_op, H_op, eff_op), ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'BackgroundColor', 'white', 'EdgeColor', 'black', 'LineWidth', 1);
    
    % ═════════════════════════════════════════════════════════════════════
    % MARK STATIC HEAD
    % ═════════════════════════════════════════════════════════════════════
    
    H_static = results.system_curve.H_static;
    plot([0, max(Q_sys)], [H_static, H_static], 'b:', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Static Head (%.1f m)', H_static));
    
    % ═════════════════════════════════════════════════════════════════════
    % FORMATTING
    % ═════════════════════════════════════════════════════════════════════
    
    yyaxis left;  % Format left axis
    xlabel('Flow Rate (L/s)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Head (m)', 'FontSize', 12, 'FontWeight', 'bold');
    title('System Curve and Pump Performance', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Axis limits
    xlim([0, max(Q_sys)*1.1]);
    ylim([0, max([max(H_sys), max(H_pump)])*1.15]);
    set(gca, 'YColor', 'k');
    
    % Legend
    legend('Location', 'northeast', 'FontSize', 10);
    
    % Grid
    grid on;
    set(gca, 'GridLineStyle', '-', 'GridAlpha', 0.3);
    
    % Add info box
    info_text = sprintf(['System Information:\n' ...
                        'Pipe: DN%.0f, %.0f m\n' ...
                        'Flow: %.1f L/s\n' ...
                        'Static Head: %.1f m\n' ...
                        'Total Head Loss: %.2f m\n' ...
                        'Pump Type: %s'], ...
                        results.inputs.pipe.diameter*1000, ...
                        results.inputs.pipe.length, ...
                        results.flow.Q*1000, ...
                        H_static, ...
                        results.total_losses.h_L, ...
                        results.pump_selection.type);
    
    annotation('textbox', [0.15, 0.65, 0.25, 0.20], ...
        'String', info_text, ...
        'FontSize', 9, 'BackgroundColor', 'white', 'EdgeColor', 'black', ...
        'LineWidth', 1.5, 'FitBoxToText', 'on');
    
    hold off;
    
    % ═════════════════════════════════════════════════════════════════════
    % SAVE FIGURE
    % ═════════════════════════════════════════════════════════════════════
    
    saveas(fig, filename);
    close(fig);
end
