%% TEST FUNCTION ACCESSIBILITY
% Quick test to verify all functions are accessible
% Run this to check if the project structure is correct

clc;
fprintf('Testing Pipe Flow Analyzer Function Accessibility...\n\n');

% Add paths
addpath(genpath('src'));
addpath('data');

% Refresh MATLAB's function cache
rehash path;

fprintf('Paths configured and cache refreshed.\n\n');

% Test counter
total_tests = 0;
passed_tests = 0;

%% Test 1: Interactive functions
fprintf('[1/7] Testing interactive functions...\n');
total_tests = total_tests + 1;
try
    % These should exist as functions
    assert(exist('get_pipe_specs', 'file') == 2, 'get_pipe_specs not found');
    assert(exist('get_fittings', 'file') == 2, 'get_fittings not found');
    assert(exist('get_flow_specs', 'file') == 2, 'get_flow_specs not found');
    assert(exist('get_system_config', 'file') == 2, 'get_system_config not found');
    fprintf('  ✓ All interactive functions found\n\n');
    passed_tests = passed_tests + 1;
catch ME
    fprintf('  ✗ FAILED: %s\n\n', ME.message);
end

%% Test 2: Core calculation functions
fprintf('[2/7] Testing core calculation functions...\n');
total_tests = total_tests + 1;
try
    % Check if files exist
    assert(exist('calculate_losses', 'file') == 2, 'calculate_losses not found');
    
    % Special check for get_f_from_moody_chart
    moody_path = which('get_f_from_moody_chart');
    if isempty(moody_path)
        error('get_f_from_moody_chart not found on path. Please run: addpath(genpath(''src''));');
    end
    
    assert(exist('calculate_egl_hgl', 'file') == 2, 'calculate_egl_hgl not found');
    assert(exist('find_operating_point', 'file') == 2, 'find_operating_point not found');
    fprintf('  ✓ All core functions found\n');
    fprintf('    get_f_from_moody_chart: %s\n\n', moody_path);
    passed_tests = passed_tests + 1;
catch ME
    fprintf('  ✗ FAILED: %s\n\n', ME.message);
end

%% Test 3: Data access functions
fprintf('[3/7] Testing data access functions...\n');
total_tests = total_tests + 1;
try
    assert(exist('get_water_properties_coolprop', 'file') == 2, 'get_water_properties_coolprop not found');
    assert(exist('get_fitting_K', 'file') == 2, 'get_fitting_K not found');
    assert(exist('get_pipe_roughness', 'file') == 2, 'get_pipe_roughness not found');
    assert(exist('load_pump_database', 'file') == 2, 'load_pump_database not found');
    fprintf('  ✓ All data functions found\n\n');
    passed_tests = passed_tests + 1;
catch ME
    fprintf('  ✗ FAILED: %s\n\n', ME.message);
end

%% Test 4: Output generation functions
fprintf('[4/7] Testing output generation functions...\n');
total_tests = total_tests + 1;
try
    assert(exist('generate_report', 'file') == 2, 'generate_report not found');
    assert(exist('plot_moody_diagram', 'file') == 2, 'plot_moody_diagram not found');
    assert(exist('plot_system_pump_curves', 'file') == 2, 'plot_system_pump_curves not found');
    assert(exist('plot_egl_hgl_profile', 'file') == 2, 'plot_egl_hgl_profile not found');
    assert(exist('plot_pressure_profile', 'file') == 2, 'plot_pressure_profile not found');
    fprintf('  ✓ All output functions found\n\n');
    passed_tests = passed_tests + 1;
catch ME
    fprintf('  ✗ FAILED: %s\n\n', ME.message);
end

%% Test 5: Static data functions
fprintf('[5/7] Testing static data functions...\n');
total_tests = total_tests + 1;
try
    assert(exist('create_pump_database', 'file') == 2, 'create_pump_database not found');
    fprintf('  ✓ Pump database creator found\n\n');
    passed_tests = passed_tests + 1;
catch ME
    fprintf('  ✗ FAILED: %s\n\n', ME.message);
end

%% Test 6: Function execution test (friction factor)
fprintf('[6/7] Testing function execution (friction factor)...\n');
total_tests = total_tests + 1;
try
    [f, regime] = get_f_from_moody_chart(100000, 0.00046);
    assert(f > 0 && f < 0.1, 'Friction factor out of range');
    assert(strcmp(regime, 'Turbulent'), 'Wrong flow regime');
    fprintf('  ✓ Friction factor calculation works (f = %.4f, %s)\n\n', f, regime);
    passed_tests = passed_tests + 1;
catch ME
    fprintf('  ✗ FAILED: %s\n\n', ME.message);
end

%% Test 7: Function execution test (water properties)
fprintf('[7/7] Testing function execution (water properties)...\n');
total_tests = total_tests + 1;
try
    [rho, mu, ~, ~] = get_water_properties_coolprop(20);
    assert(rho > 990 && rho < 1010, 'Density out of range');
    assert(mu > 0.0008 && mu < 0.0012, 'Viscosity out of range');
    fprintf('  ✓ Water properties calculation works (rho = %.1f kg/m³, mu = %.3e Pa·s)\n\n', rho, mu);
    passed_tests = passed_tests + 1;
catch ME
    fprintf('  ✗ FAILED: %s\n\n', ME.message);
end

%% Summary
fprintf('═══════════════════════════════════════════════════════════════\n');
fprintf('TEST SUMMARY\n');
fprintf('═══════════════════════════════════════════════════════════════\n\n');
fprintf('Tests passed: %d/%d\n\n', passed_tests, total_tests);

if passed_tests == total_tests
    fprintf('✓✓✓ ALL TESTS PASSED ✓✓✓\n');
    fprintf('The Pipe Flow Analyzer is ready to use!\n');
    fprintf('Run: main_analyzer\n\n');
else
    fprintf('✗✗✗ SOME TESTS FAILED ✗✗✗\n');
    fprintf('Please check the error messages above.\n\n');
end
