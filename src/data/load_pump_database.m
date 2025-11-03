function pump_db = load_pump_database()
    %% LOAD PUMP DATABASE
    % Loads pump database, creating it if not already cached
    %
    % Output:
    %   pump_db - Array of pump structures (1x10)
    
    % Check if database file exists
    db_file = fullfile('data', 'pump_database.mat');
    
    if isfile(db_file)
        % Load existing database
        load(db_file, 'pump_db');
    else
        % Create new database and save
        pump_db = create_pump_database();
        save(db_file, 'pump_db');
    end
end
