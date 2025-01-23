function [data_cell, data_RPA_cell, fqs, tps] = LT_CBP_data_load(cfg)

% LT_CBP_data_load: Loads fNIRS wavelet transform coherence (WTC) data for analysis
% Inputs:
%   - cfg: Configuration structure containing analysis parameters and paths
% Outputs:
%   - data_cell: Cell array containing WTC data for real participant pairs
%   - data_RPA_cell: Cell array containing WTC data for random permutation averages (RPA)
%   - fqs: Frequency points after loading and resampling
%   - tps: Time points after loading and resampling

% Carolina Pletti, 2025 (carolina.pletti@gmail.com)


    % ---------------------------------------------------------------------
    % Initialize list of all sources for all groups
    % ---------------------------------------------------------------------
    cfg.sources = [];

    for g = cfg.groups
        cfg.currentGroup = g{:};
        cfg.rawGrDir = strcat(cfg.rawDir,cfg.currentGroup,'\');

        %identify all file in the group subdirectory
        sourceList    = dir([cfg.rawGrDir, '*_*']); % List all files matching the pattern
        sourceList    = struct2cell(sourceList); % Convert the structure to a cell array
        sourceList    = sourceList(1,:); % Extract only the filenames
        cfg.sources = [cfg.sources, sourceList]; % Append to the list of sources

    end

    
    % ---------------------------------------------------------------------
    % Set up for data loading and storage
    % ---------------------------------------------------------------------
    numOfSources = length(cfg.sources); % Number of source files
    cfg.dataDir = cfg.srcDir; % Set the directory where data will be loaded from

    % Prepare empty cell arrays to store data for each channel
    % Channels correspond to specific regions of interest (ROIs) or ROI pairs:
    % 1 - IFGr-IFGr
    % 2 - IFGl-IFGl
    % 3 - TPJr-TPJr
    % 4 - TPJl-TPJl
    % 5 - IFGr-IFGl (or IFGl-IFGr)
    % 6 - TPJr-TPJl (or TPJl-TPJr)
    % 7 - IFGr-TPJr (or TPJr-IFGr)
    % 8 - IFGl-TPJl (or TPJl-IFGl)
    % 9 - IFGr-TPJl (or TPJl-IFGr)
    % 10 - IFGl-TPJr (or TPJr-IFGl)

    data_cell = cell(1, 10); % Store real data
    data_RPA_cell = cell(1, 10); % Store random permutation averages (RPA)

    subj = 0; % Counter for valid subjects
    for id = 1:numOfSources
        % -----------------------------------------------------------------
        % Retrieve and set up configuration for the current participant
        % -----------------------------------------------------------------
        cfg_part = cfg; % Clone the main configuration structure
        cfg_part.currentPair = cfg_part.sources{id}; % Get the current participant pair
        group_pair = strsplit(cfg_part.currentPair, '_'); % Split the pair name to identify the group
        cfg_part.currentGroup = group_pair{1}; % Assign the group name
        
        % Construct file paths for real and RPA data
        cfg_part.srcDir = strcat(cfg_part.dataDir, cfg_part.currentGroup, '\', cfg_part.segment, '\preprocessed\Coherence_ROIs');
        cfg_part.RPAsrcDir = strcat(cfg_part.dataDir, cfg_part.currentGroup, '\', cfg_part.segment, '\preprocessed\Coherence_ROIs_RPA\', cfg_part.currentPair);
        
        fprintf('loading participant %s \n', cfg_part.currentPair)
        filename = sprintf('%s\\%s.mat',cfg_part.srcDir, cfg_part.currentPair);
        filename_RPA = sprintf('%s\\%s_avg.mat',cfg_part.RPAsrcDir, cfg_part.currentPair);
        
        % -----------------------------------------------------------------
        % Load coherence data
        % -----------------------------------------------------------------
        
        try
            % Attempt to load real and RPA data
            data_real = load(filename); 
            data_RPA = load(filename_RPA); 
            subj = subj + 1; % Increment valid subject counter
        catch
            % If loading fails, skip the participant and display a warning
            fprintf('no coherence file avaliable for pair %s \n', cfg_part.currentPair)
            continue
        end
        
        % -----------------------------------------------------------------
        % Process and store data for the current participant
        % -----------------------------------------------------------------
        
        % Load real data into the data_cell array
        [data_cell, fqs, tps] = LT_CBP_load(data_cell, data_real, subj, cfg);
        % Load RPA data into the data_RPA_cell array
        [data_RPA_cell, fqs, tps] = LT_CBP_load(data_RPA_cell, data_RPA, subj, cfg);

    end
end