function [pump_idx, Q_op, H_op, eff_op] = find_operating_point(pump_db, H_sys, Q_range, h_pump, Q_design)
    %% FIND OPERATING POINT AND SELECT OPTIMAL PUMP
    % Determines pump-system intersection and selects best pump
    %
    % Input:
    %   pump_db - Array of pump structures
    %   H_sys - System curve head values (m)
    %   Q_range - System curve flow values (m³/s)
    %   h_pump - Required head at design point (m)
    %   Q_design - Design flow rate (m³/s)
    % Output:
    %   pump_idx - Index of selected pump in database
    %   Q_op - Operating flow rate (m³/s)
    %   H_op - Operating head (m)
    %   eff_op - Operating efficiency (0-1)
    %
    % Selection Criteria:
    %   1. Pump must meet or exceed required head
    %   2. Operating point should be near best efficiency point (BEP)
    %   3. Prefer flow rate close to design flow
    %   4. Avoid operation at extremes of pump curve
    
    n_pumps = length(pump_db);
    
    % Storage for candidate operating points
    candidates = struct('pump_idx', {}, 'Q_op', {}, 'H_op', {}, ...
                        'eff_op', {}, 'score', {});
    candidate_count = 0;
    
    % Evaluate each pump
    for i = 1:n_pumps
        % Extract pump curve data
        Q_p = pump_db(i).curve_Q / 1000;  % Convert L/s to m³/s
        H_p = pump_db(i).curve_H;         % Head in m
        eff_p = pump_db(i).curve_efficiency;  % Efficiency (0-1)
        
        % Check if pump range covers the required operating point
        if max(H_p) < h_pump * 0.9  % Pump too weak
            continue;
        end
        if min(Q_p) > Q_design * 1.5  % Pump too large
            continue;
        end
        
        % Find intersection of pump curve and system curve
        try
            % Create fine interpolation for both curves
            Q_fine = linspace(max(min(Q_p), min(Q_range)), ...
                              min(max(Q_p), max(Q_range)), 500);
            
            % Interpolate pump curve
            H_p_fine = interp1(Q_p, H_p, Q_fine, 'pchip', 'extrap');
            
            % Interpolate system curve
            H_sys_fine = interp1(Q_range, H_sys, Q_fine, 'linear', 'extrap');
            
            % Find intersection (where curves are closest)
            [~, idx_intersect] = min(abs(H_p_fine - H_sys_fine));
            
            Q_op = Q_fine(idx_intersect);
            H_op = H_p_fine(idx_intersect);
            
            % Get efficiency at operating point
            eff_op = interp1(Q_p, eff_p, Q_op, 'pchip', 'extrap');
            
            % Ensure efficiency is in valid range
            eff_op = max(0.01, min(1.0, eff_op));
            
            % Calculate selection score (lower is better)
            % Score based on: flow deviation, efficiency, and head margin
            flow_deviation = abs(Q_op - Q_design) / Q_design;
            efficiency_penalty = (1 - eff_op);  % Prefer high efficiency
            head_margin = (H_op - h_pump) / h_pump;  % Prefer small positive margin
            
            % Penalize operation too far from BEP
            Q_BEP = pump_db(i).Q_BEP / 1000;  % Convert to m³/s
            BEP_deviation = abs(Q_op - Q_BEP) / Q_BEP;
            
            % Combined score (weighted)
            score = 1.0 * flow_deviation + ...
                    2.0 * efficiency_penalty + ...
                    0.5 * abs(head_margin) + ...
                    1.5 * BEP_deviation;
            
            % Only accept if head requirement is met
            if H_op >= h_pump * 0.95  % Allow 5% tolerance
                candidate_count = candidate_count + 1;
                candidates(candidate_count).pump_idx = i;
                candidates(candidate_count).Q_op = Q_op;
                candidates(candidate_count).H_op = H_op;
                candidates(candidate_count).eff_op = eff_op;
                candidates(candidate_count).score = score;
            end
            
        catch
            % Skip pump if interpolation fails
            continue;
        end
    end
    
    % Select best pump from candidates
    if candidate_count == 0
        % No suitable pump found - select pump with highest head
        warning('No pump found meeting requirements. Selecting highest head pump.');
        
        max_head = 0;
        pump_idx = 1;
        for i = 1:n_pumps
            if pump_db(i).H_shutoff > max_head
                max_head = pump_db(i).H_shutoff;
                pump_idx = i;
            end
        end
        
        % Use approximate operating point
        Q_op = Q_design;
        H_op = h_pump * 1.1;  % 10% margin
        eff_op = 0.70;  % Assume 70% efficiency
        
    else
        % Select candidate with best score
        scores = [candidates.score];
        [~, best_idx] = min(scores);
        
        pump_idx = candidates(best_idx).pump_idx;
        Q_op = candidates(best_idx).Q_op;
        H_op = candidates(best_idx).H_op;
        eff_op = candidates(best_idx).eff_op;
    end
end
