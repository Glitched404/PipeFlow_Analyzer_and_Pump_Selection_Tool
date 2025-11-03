function plot_egl_hgl_profile(results, filename)
    %% PLOT ENERGY GRADE LINE (EGL) AND HYDRAULIC GRADE LINE (HGL)
    % Shows energy and hydraulic grade lines along pipe with elevation profile
    %
    % Input:
    %   results - Results structure with egl_hgl field
    %   filename - Output file path for PNG
    
    % Create figure
    fig = figure('Position', [100, 100, 1000, 700], 'Visible', 'off');
    hold on;
    grid on;
    
    % ═════════════════════════════════════════════════════════════════════
    % EXTRACT DATA
    % ═════════════════════════════════════════════════════════════════════
    
    x = results.egl_hgl.x;           % Position along pipe (m)
    EGL = results.egl_hgl.EGL;       % Energy grade line (m)
    HGL = results.egl_hgl.HGL;       % Hydraulic grade line (m)
    elev = results.egl_hgl.elevation;  % Pipe centerline elevation (m)
    
    % ═════════════════════════════════════════════════════════════════════
    % PLOT PIPE ELEVATION
    % ═════════════════════════════════════════════════════════════════════
    
    % Pipe diameter for visualization
    D = results.inputs.pipe.diameter;
    
    % Plot pipe as filled area
    fill([x, fliplr(x)], [elev - D/2, fliplr(elev + D/2)], ...
        [0.7 0.7 0.7], 'FaceAlpha', 0.5, 'EdgeColor', 'k', 'LineWidth', 1.5, ...
        'DisplayName', 'Pipe');
    
    % Plot centerline
    plot(x, elev, 'k--', 'LineWidth', 1, 'DisplayName', 'Pipe Centerline');
    
    % ═════════════════════════════════════════════════════════════════════
    % PLOT EGL AND HGL
    % ═════════════════════════════════════════════════════════════════════
    
    % Energy Grade Line (EGL)
    plot(x, EGL, 'r-', 'LineWidth', 2.5, 'DisplayName', 'Energy Grade Line (EGL)');
    
    % Hydraulic Grade Line (HGL)
    plot(x, HGL, 'b-', 'LineWidth', 2.5, 'DisplayName', 'Hydraulic Grade Line (HGL)');
    
    % ═════════════════════════════════════════════════════════════════════
    % MARK FITTING LOCATIONS WITH DISCRETE ENERGY DROPS
    % ═════════════════════════════════════════════════════════════════════
    
    % Get fitting information
    if isfield(results.inputs, 'fittings') && ~isempty(results.inputs.fittings)
        % Find all duplicate x-positions (these indicate discrete drops)
        for i = 2:length(x)
            if abs(x(i) - x(i-1)) < 1e-6  % Same position = discrete drop
                % Draw vertical lines for discrete drops on both EGL and HGL
                plot([x(i), x(i)], [EGL(i-1), EGL(i)], 'r-', ...
                    'LineWidth', 2.5, 'HandleVisibility', 'off');
                plot([x(i), x(i)], [HGL(i-1), HGL(i)], 'r-', ...
                    'LineWidth', 2.5, 'HandleVisibility', 'off');
                
                % Mark the drop points
                plot(x(i), EGL(i), 'ro', 'MarkerSize', 6, ...
                    'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
                plot(x(i), HGL(i), 'ro', 'MarkerSize', 6, ...
                    'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
            end
        end
        
        % Add legend entry for fittings
        plot(NaN, NaN, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r', ...
            'DisplayName', 'Fitting Locations');
    end
    
    % ═════════════════════════════════════════════════════════════════════
    % MARK KEY POINTS
    % ═════════════════════════════════════════════════════════════════════
    
    % Inlet point
    plot(x(1), EGL(1), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'LineWidth', 2);
    text(x(1), EGL(1) + 0.5, 'Inlet', 'FontSize', 9, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left', 'BackgroundColor', 'white');
    
    % Outlet point
    plot(x(end), EGL(end), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'LineWidth', 2);
    text(x(end), EGL(end) + 0.5, 'Outlet', 'FontSize', 9, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'right', 'BackgroundColor', 'white');
    
    % ═════════════════════════════════════════════════════════════════════
    % SHOW VELOCITY HEAD
    % ═════════════════════════════════════════════════════════════════════
    
    % Velocity head (constant for constant diameter)
    V_head = EGL(1) - HGL(1);
    
    % Draw vertical line showing velocity head at midpoint
    mid_idx = round(length(x)/2);
    plot([x(mid_idx), x(mid_idx)], [HGL(mid_idx), EGL(mid_idx)], ...
        'g-', 'LineWidth', 2, 'DisplayName', sprintf('Velocity Head (%.2f m)', V_head));
    
    % Add annotation
    text(x(mid_idx) + 1, (HGL(mid_idx) + EGL(mid_idx))/2, ...
        sprintf('V²/(2g) = %.2f m', V_head), ...
        'FontSize', 9, 'FontWeight', 'bold', 'Color', 'g', ...
        'BackgroundColor', 'white', 'EdgeColor', 'g');
    
    % ═════════════════════════════════════════════════════════════════════
    % SHOW HEAD LOSS
    % ═════════════════════════════════════════════════════════════════════
    
    % Draw vertical line showing total head loss
    h_L = results.total_losses.h_L;
    plot([x(end), x(end)], [EGL(end), EGL(1)], 'r:', 'LineWidth', 2);
    text(x(end) - 2, (EGL(end) + EGL(1))/2, ...
        sprintf('Total Loss\nh_L = %.2f m', h_L), ...
        'FontSize', 9, 'FontWeight', 'bold', 'Color', 'r', ...
        'BackgroundColor', 'white', 'EdgeColor', 'r', ...
        'HorizontalAlignment', 'right');
    
    % ═════════════════════════════════════════════════════════════════════
    % FORMATTING
    % ═════════════════════════════════════════════════════════════════════
    
    xlabel('Distance Along Pipe (m)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Elevation / Head (m)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Energy Grade Line (EGL) and Hydraulic Grade Line (HGL) Profile', ...
        'FontSize', 14, 'FontWeight', 'bold');
    
    % Axis limits with some margin
    xlim([0, max(x)]);
    y_min = min([elev - D, HGL, EGL]) - 2;
    y_max = max([elev + D, HGL, EGL]) + 2;
    ylim([y_min, y_max]);
    
    % Legend
    legend('Location', 'best', 'FontSize', 9);
    
    % Grid
    grid on;
    set(gca, 'GridLineStyle', '-', 'GridAlpha', 0.3);
    
    % Add info box
    info_text = sprintf(['System Details:\n' ...
                        'Pipe Length: %.1f m\n' ...
                        'Diameter: %.0f mm\n' ...
                        'Flow: %.1f L/s\n' ...
                        'Velocity: %.2f m/s\n' ...
                        'Re: %.0f (%s)\n' ...
                        'Friction Factor: %.4f'], ...
                        results.inputs.pipe.length, ...
                        results.inputs.pipe.diameter*1000, ...
                        results.flow.Q*1000, ...
                        results.flow.V, ...
                        results.flow.Re, ...
                        results.flow.regime, ...
                        results.friction.f);
    
    annotation('textbox', [0.15, 0.15, 0.25, 0.25], ...
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
