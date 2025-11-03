function fittings = get_fittings(pipe_length)
    %% GET FITTINGS FROM USER WITH SEQUENTIAL POSITIONING
    % Interactive function to collect fitting/component information with positions
    %
    % Input:
    %   pipe_length - Total length of pipe (m) for position validation
    %
    % Output:
    %   fittings - Struct array (Nx1) with fields:
    %       .type (string) - Fitting code (lowercase)
    %       .K (scalar) - Loss coefficient
    %       .position (scalar) - Distance from inlet (m)
    %       .name (string) - Display name
    
    % Initialize empty structure array
    fittings = struct('type', {}, 'K', {}, 'position', {}, 'name', {});
    count = 0;
    
    fprintf('Available fittings (press ENTER without input to finish):\n');
    fprintf('  [A] 90° Standard Elbow (K = 0.9)\n');
    fprintf('  [B] 90° Long Radius Elbow (K = 0.6)\n');
    fprintf('  [C] 45° Elbow (K = 0.4)\n');
    fprintf('  [D] Tee - Through Flow (K = 0.6)\n');
    fprintf('  [E] Tee - Branch Flow (K = 1.8)\n');
    fprintf('  [F] Gate Valve (Open) (K = 0.2)\n');
    fprintf('  [G] Globe Valve (Open) (K = 10.0)\n');
    fprintf('  [H] Ball Valve (Open) (K = 0.05)\n');
    fprintf('  [I] Check Valve (K = 2.0)\n');
    fprintf('  [J] Sudden Expansion (K = 1.0)\n');
    fprintf('  [K] Sudden Contraction (K = 0.5)\n');
    fprintf('  [L] Sharp Entrance (K = 0.5)\n');
    fprintf('  [M] Rounded Entrance (K = 0.04)\n');
    fprintf('  [N] Exit (K = 1.0)\n');
    fprintf('  [ENTER] Done adding fittings\n\n');
    
    fprintf('═══════════════════════════════════════════════════════════════\n');
    fprintf('Enter fittings SEQUENTIALLY along the pipe (inlet to outlet)\n');
    fprintf('Pipe length: %.2f m (positions must be between 0 and %.2f m)\n', pipe_length, pipe_length);
    fprintf('Tip: You can add the same fitting type multiple times at different positions\n');
    fprintf('═══════════════════════════════════════════════════════════════\n\n');
    
    % Loop to collect up to 50 fittings (more flexible now)
    while count < 50
        prompt = sprintf('Fitting %d - Select type [ENTER to finish]: ', count + 1);
        fitting_code = input(prompt, 's');
        
        % Exit loop if user presses ENTER
        if isempty(fitting_code)
            break;
        end
        
        % Get K-factor and name
        try
            [K, name] = get_fitting_K(fitting_code);
        catch
            fprintf('✗ Invalid code. Please try again.\n\n');
            continue;
        end
        
        % Get position along pipe
        prompt = sprintf('Fitting %d - Position along pipe (0 to %.2f m): ', count + 1, pipe_length);
        position = input(prompt);
        
        % Validation
        if isempty(position) || position < 0 || position > pipe_length
            fprintf('⚠ Invalid position (must be 0 to %.2f m). Skipping this fitting.\n\n', pipe_length);
            continue;
        end
        
        % Add to array
        count = count + 1;
        fittings(count).type = lower(fitting_code);
        fittings(count).K = K;
        fittings(count).position = position;
        fittings(count).name = name;
        
        fprintf('✓ Added: %s at %.2f m\n\n', name, position);
    end
    
    % Sort fittings by position (inlet to outlet)
    if count > 0
        positions = [fittings.position];
        [~, sort_idx] = sort(positions);
        fittings = fittings(sort_idx);
        
        fprintf('\n═══════════════════════════════════════════════════════════════\n');
        fprintf('Summary of fittings (sorted by position):\n');
        fprintf('═══════════════════════════════════════════════════════════════\n');
        for i = 1:length(fittings)
            fprintf('  %d. %s at %.2f m (K = %.2f)\n', i, fittings(i).name, fittings(i).position, fittings(i).K);
        end
        fprintf('═══════════════════════════════════════════════════════════════\n\n');
    end
    
    % If no fittings added, use default entrance + exit
    if count == 0
        fprintf('⚠ No fittings specified. Using default: Entrance + Exit\n');
        
        fittings(1).type = 'm';
        fittings(1).K = 0.04;
        fittings(1).position = 0.0;
        fittings(1).name = 'Rounded Entrance';
        
        fittings(2).type = 'n';
        fittings(2).K = 1.0;
        fittings(2).position = pipe_length;
        fittings(2).name = 'Exit';
        
        fprintf('✓ Applied: Rounded Entrance at 0.0 m + Exit at %.2f m\n', pipe_length);
    end
end
