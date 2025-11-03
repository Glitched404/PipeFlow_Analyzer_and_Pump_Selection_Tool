function plot_moody_diagram(results, filename)
    %% PLOT MOODY DIAGRAM WITH OPERATING POINT
    % Creates Moody chart showing friction factor vs Reynolds number
    % with operating point marked
    %
    % Input:
    %   results - Results structure with moody field
    %   filename - Output file path for PNG
    
    % Create figure
    fig = figure('Position', [100, 100, 1000, 700], 'Visible', 'off');
    
    % ═════════════════════════════════════════════════════════════════════
    % GENERATE MOODY CHART DATA
    % ═════════════════════════════════════════════════════════════════════
    
    % Reynolds number range (log scale)
    Re_range = logspace(2.5, 8, 200);  % 316 to 100,000,000
    
    % Relative roughness values to plot
    eps_D_values = [0, 0.000001, 0.000005, 0.00001, 0.00005, ...
                    0.0001, 0.0002, 0.0004, 0.0006, 0.001, ...
                    0.002, 0.004, 0.006, 0.01, 0.015, 0.02, 0.03, 0.04, 0.05];
    
    % Colors for different roughness curves
    n_curves = length(eps_D_values);
    colors = jet(n_curves);
    
    % Plot each roughness curve
    hold on;
    grid on;
    
    for i = 1:length(eps_D_values)
        eps_D = eps_D_values(i);
        f_values = zeros(size(Re_range));
        
        for j = 1:length(Re_range)
            [f_values(j), ~] = get_f_from_moody_chart(Re_range(j), eps_D);
        end
        
        % Plot curve
        if eps_D == 0
            % Smooth pipe (laminar + turbulent)
            plot(Re_range, f_values, 'k-', 'LineWidth', 1.5);
        else
            % Rough pipes
            plot(Re_range, f_values, 'Color', colors(i,:), 'LineWidth', 1.2);
        end
    end
    
    % ═════════════════════════════════════════════════════════════════════
    % ADD LAMINAR FLOW LINE
    % ═════════════════════════════════════════════════════════════════════
    
    Re_laminar = logspace(2.5, log10(2300), 50);
    f_laminar = 64 ./ Re_laminar;
    plot(Re_laminar, f_laminar, 'b--', 'LineWidth', 2);
    
    % ═════════════════════════════════════════════════════════════════════
    % MARK OPERATING POINT
    % ═════════════════════════════════════════════════════════════════════
    
    Re_op = results.moody.Re;
    f_op = results.moody.f;
    
    % Plot operating point
    plot(Re_op, f_op, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r', 'LineWidth', 2);
    
    % Add text label
    text(Re_op * 1.3, f_op, sprintf('Operating Point\nRe = %.0f\nf = %.4f', Re_op, f_op), ...
        'FontSize', 10, 'FontWeight', 'bold', 'Color', 'r', ...
        'BackgroundColor', 'white', 'EdgeColor', 'red', 'LineWidth', 1);
    
    % ═════════════════════════════════════════════════════════════════════
    % FORMATTING
    % ═════════════════════════════════════════════════════════════════════
    
    % Logarithmic scales
    set(gca, 'XScale', 'log', 'YScale', 'log');
    
    % Axis limits
    xlim([1e3, 1e8]);
    ylim([0.008, 0.10]);
    
    % Labels and title
    xlabel('Reynolds Number (Re)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Darcy Friction Factor (f)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Moody Diagram - Friction Factor vs Reynolds Number', ...
        'FontSize', 14, 'FontWeight', 'bold');
    
    % Add legend for key curves
    legend_entries = {'Smooth Pipe', 'Laminar (f = 64/Re)', 'Operating Point'};
    legend(legend_entries, 'Location', 'southwest', 'FontSize', 9);
    
    % Add annotation for relative roughness
    annotation('textbox', [0.65, 0.15, 0.25, 0.15], ...
        'String', sprintf('Operating Point:\nε/D = %.6f\nRegime: %s', ...
                          results.moody.eps_D, results.flow.regime), ...
        'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black', ...
        'LineWidth', 1.5);
    
    % Add flow regime zones
    patch([1e3 2.3e3 2.3e3 1e3], [0.008 0.008 0.10 0.10], ...
        [0.9 0.9 1.0], 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    text(1.5e3, 0.015, 'Laminar', 'FontSize', 9, 'Rotation', 90, ...
        'Color', [0.5 0.5 0.5], 'FontWeight', 'bold');
    
    patch([2.3e3 4e3 4e3 2.3e3], [0.008 0.008 0.10 0.10], ...
        [1.0 1.0 0.9], 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    text(2.9e3, 0.015, 'Trans.', 'FontSize', 8, 'Rotation', 90, ...
        'Color', [0.5 0.5 0.5], 'FontWeight', 'bold');
    
    patch([4e3 1e8 1e8 4e3], [0.008 0.008 0.10 0.10], ...
        [0.9 1.0 0.9], 'FaceAlpha', 0.05, 'EdgeColor', 'none');
    text(1e4, 0.015, 'Turbulent', 'FontSize', 9, 'Rotation', 90, ...
        'Color', [0.5 0.5 0.5], 'FontWeight', 'bold');
    
    % Grid
    grid on;
    set(gca, 'GridLineStyle', '-', 'GridAlpha', 0.3);
    set(gca, 'MinorGridLineStyle', ':', 'MinorGridAlpha', 0.2);
    
    hold off;
    
    % ═════════════════════════════════════════════════════════════════════
    % SAVE FIGURE
    % ═════════════════════════════════════════════════════════════════════
    
    saveas(fig, filename);
    close(fig);
end
