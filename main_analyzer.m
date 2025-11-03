function main_analyzer()
    %% PIPE FLOW ANALYZER - INTERACTIVE MODE
    % Main entry point with menu-driven interface
    % Run this file to start the application
    %
    % Features:
    %   - Interactive menu system (create new / load previous / exit)
    %   - 4-step user input workflow
    %   - Automatic calculation and output generation
    %   - Save/load functionality with timestamps
    %
    % Author: Fluid Mechanics Tool Suite
    % Version: 1.0
    
    clc;
    fprintf('\n');
    fprintf('╔═══════════════════════════════════════════════════════════╗\n');
    fprintf('║  PIPE FLOW ANALYZER - INTERACTIVE MODE                   ║\n');
    fprintf('║  Fluid Mechanics & Pipe System Design Tool               ║\n');
    fprintf('╚═══════════════════════════════════════════════════════════╝\n\n');
    
    % Add all source directories to MATLAB path
    addpath(genpath('src'));  % Adds all subdirectories
    addpath('data');
    rehash path;  % Refresh MATLAB's function cache
    
    % Ensure directories exist
    if ~exist('inputs', 'dir'), mkdir('inputs'); end
    if ~exist('outputs', 'dir'), mkdir('outputs'); end
    
    % Main menu loop
    while true
        fprintf('Would you like to:\n');
        fprintf('  [1] Create new analysis\n');
        fprintf('  [2] Load previous analysis\n');
        fprintf('  [3] Exit\n\n');
        
        choice = input('Your choice: ', 's');
        
        switch choice
            case '1'
                run_new_analysis();
                break;
                
            case '2'
                run_loaded_analysis();
                break;
                
            case '3'
                fprintf('\n✓ Thank you for using Pipe Flow Analyzer!\n\n');
                return;
                
            otherwise
                fprintf('\n✗ Invalid choice. Please enter 1, 2, or 3.\n\n');
        end
    end
end

function run_new_analysis()
    %% RUN NEW INTERACTIVE ANALYSIS
    % Guides user through 4-step input process, saves inputs, runs calculations
    
    fprintf('\n');
    fprintf('─────────────────────────────────────────────────────────────\n');
    fprintf('STEP 1: PIPE SPECIFICATIONS\n');
    fprintf('─────────────────────────────────────────────────────────────\n\n');
    pipe_specs = get_pipe_specs();
    
    fprintf('\n');
    fprintf('─────────────────────────────────────────────────────────────\n');
    fprintf('STEP 2: FITTINGS & COMPONENTS\n');
    fprintf('─────────────────────────────────────────────────────────────\n\n');
    fittings = get_fittings(pipe_specs.length);
    
    fprintf('\n');
    fprintf('─────────────────────────────────────────────────────────────\n');
    fprintf('STEP 3: FLOW SPECIFICATIONS\n');
    fprintf('─────────────────────────────────────────────────────────────\n\n');
    flow_specs = get_flow_specs(pipe_specs);
    
    fprintf('\n');
    fprintf('─────────────────────────────────────────────────────────────\n');
    fprintf('STEP 4: SYSTEM CONFIGURATION\n');
    fprintf('─────────────────────────────────────────────────────────────\n\n');
    system_config = get_system_config();
    
    % Combine all inputs into structure
    inputs = struct();
    inputs.pipe = pipe_specs;
    inputs.fittings = fittings;
    inputs.flow = flow_specs;
    inputs.system = system_config;
    inputs.timestamp = datetime('now');
    
    % Display summary
    fprintf('\n');
    fprintf('─────────────────────────────────────────────────────────────\n');
    fprintf('SUMMARY OF INPUTS\n');
    fprintf('─────────────────────────────────────────────────────────────\n\n');
    
    fprintf('Pipe: DN%.0f (%.0f mm ID), %.1f m, %s\n', ...
        inputs.pipe.diameter*1000, inputs.pipe.diameter*1000, ...
        inputs.pipe.length, inputs.pipe.material_name);
    
    fprintf('Fluid: Water at %.0f°C\n', inputs.flow.temperature);
    
    fprintf('Flow: %.1f L/s (%.2f m/s)\n', ...
        inputs.flow.Q*1000, inputs.flow.V);
    
    K_total = sum([inputs.fittings(:).K]);
    fprintf('Fittings: %d components (Total K = %.2f)\n', ...
        length(inputs.fittings), K_total);
    
    fprintf('Elevation: %.1f → %.1f m\n', ...
        inputs.system.z_inlet, inputs.system.z_outlet);
    
    % Ask to save
    fprintf('\n');
    fprintf('Save these parameters?\n');
    fprintf('  [Y] Yes - Save and continue with analysis\n');
    fprintf('  [N] No - Re-enter parameters\n');
    fprintf('  [E] Exit without saving\n\n');
    
    save_choice = upper(input('Your choice [Y]: ', 's'));
    if isempty(save_choice), save_choice = 'Y'; end
    
    switch save_choice
        case 'Y'
            % Generate filename with timestamp
            timestamp = datestr(inputs.timestamp, 'yyyy-mm-dd_HHMMSS');
            filename = fullfile('inputs', sprintf('run_%s.mat', timestamp));
            
            % Save inputs
            save(filename, 'inputs');
            fprintf('\n✓ Parameters saved to: %s\n\n', filename);
            
            % Run analysis
            fprintf('─────────────────────────────────────────────────────────────\n');
            fprintf('RUNNING ANALYSIS...\n');
            fprintf('─────────────────────────────────────────────────────────────\n\n');
            
            tic;
            results = run_calculation(inputs);
            elapsed_time = toc;
            
            fprintf('\nAnalysis completed in %.2f seconds.\n\n', elapsed_time);
            
            % Generate outputs
            generate_outputs(inputs, results, timestamp);
            
        case 'N'
            fprintf('\nRe-starting input process...\n');
            run_new_analysis();
            
        case 'E'
            fprintf('\nExiting without saving.\n\n');
            return;
            
        otherwise
            fprintf('\n✗ Invalid choice. Exiting.\n\n');
            return;
    end
end

function run_loaded_analysis()
    %% LOAD AND RUN PREVIOUS ANALYSIS
    % Lists saved analyses, loads selected file, runs calculations
    
    % List available input files
    files = dir('inputs/*.mat');
    
    if isempty(files)
        fprintf('\n✗ No previous analyses found.\n\n');
        return;
    end
    
    fprintf('\nAvailable previous analyses:\n\n');
    for i = 1:length(files)
        fprintf('  [%d] %s (%s)\n', i, files(i).name, files(i).date);
    end
    fprintf('\n');
    
    choice = input('Select file number [1]: ', 's');
    if isempty(choice), choice = '1'; end
    idx = str2double(choice);
    
    if isnan(idx) || idx < 1 || idx > length(files)
        fprintf('✗ Invalid selection.\n\n');
        return;
    end
    
    % Load inputs
    filepath = fullfile('inputs', files(idx).name);
    load(filepath, 'inputs');
    
    fprintf('\n✓ Loaded: %s\n\n', filepath);
    
    % Display summary
    fprintf('─────────────────────────────────────────────────────────────\n');
    fprintf('SUMMARY OF LOADED INPUTS\n');
    fprintf('─────────────────────────────────────────────────────────────\n\n');
    
    fprintf('Pipe: DN%.0f (%.0f mm ID), %.1f m, %s\n', ...
        inputs.pipe.diameter*1000, inputs.pipe.diameter*1000, ...
        inputs.pipe.length, inputs.pipe.material_name);
    fprintf('Flow: %.1f L/s at %.0f°C\n', inputs.flow.Q*1000, inputs.flow.temperature);
    fprintf('Fittings: %d components\n\n', length(inputs.fittings));
    
    % Run analysis
    fprintf('─────────────────────────────────────────────────────────────\n');
    fprintf('RUNNING ANALYSIS...\n');
    fprintf('─────────────────────────────────────────────────────────────\n\n');
    
    tic;
    results = run_calculation(inputs);
    elapsed_time = toc;
    
    fprintf('\nAnalysis completed in %.2f seconds.\n\n', elapsed_time);
    
    % Generate outputs
    timestamp = datestr(inputs.timestamp, 'yyyy-mm-dd_HHMMSS');
    generate_outputs(inputs, results, timestamp);
end

function results = run_calculation(inputs)
    %% RUN COMPLETE CALCULATION
    % Wrapper function that calls the main calculation engine
    %
    % Input:
    %   inputs - Structure with pipe, fittings, flow, system fields
    % Output:
    %   results - Structure with all calculation results
    
    results = calculate_losses(inputs);
end

function generate_outputs(inputs, results, timestamp)
    %% GENERATE ALL OUTPUTS
    % Creates text report and 4 plots, saves to outputs folder
    %
    % Inputs:
    %   inputs - Input parameters structure
    %   results - Calculation results structure
    %   timestamp - String timestamp for filenames
    
    % Create report
    report_file = fullfile('outputs', sprintf('flow_analysis_%s.txt', timestamp));
    generate_report(inputs, results, report_file);
    
    % Create plots
    moody_file = fullfile('outputs', sprintf('moody_diagram_%s.png', timestamp));
    plot_moody_diagram(results, moody_file);
    
    curves_file = fullfile('outputs', sprintf('system_pump_curves_%s.png', timestamp));
    plot_system_pump_curves(results, curves_file);
    
    egl_file = fullfile('outputs', sprintf('egl_hgl_profile_%s.png', timestamp));
    plot_egl_hgl_profile(results, egl_file);
    
    pressure_file = fullfile('outputs', sprintf('pressure_profile_%s.png', timestamp));
    plot_pressure_profile(results, pressure_file);
    
    fprintf('✓ Results saved to:\n');
    fprintf('  • %s\n', report_file);
    fprintf('  • %s\n', moody_file);
    fprintf('  • %s\n', curves_file);
    fprintf('  • %s\n', egl_file);
    fprintf('  • %s\n\n', pressure_file);
    
    % Ask to view results
    view_choice = input('View report now? [Y/n]: ', 's');
    if isempty(view_choice) || upper(view_choice) == 'Y'
        fprintf('\n');
        fprintf('═══════════════════════════════════════════════════════════════\n');
        fprintf('                     ANALYSIS REPORT\n');
        fprintf('═══════════════════════════════════════════════════════════════\n\n');
        type(report_file);
    end
end
