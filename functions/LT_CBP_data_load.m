function [data_cell, data_control_cell, cfg, part_list] = LT_CBP_data_load(cfg)

% LT_CBP_data_load: Loads fNIRS wavelet transform coherence (WTC) data for analysis
% Inputs:
%   - cfg: Configuration structure containing analysis parameters and paths
% Outputs:
%   - data_cell: Cell array containing WTC data for experimental participant pairs
%   - data_control_cell: Cell array containing control participants, for
%   instance WTC data for random permutation averages (RPA) or participants
%   that did not interact
%   - cfg: Configuration structure updated with the fields:
%           - fqs: Frequency points after loading and resampling
%           - tps: Time points after loading and resampling
%   - part_list: Cell array containing participant labels for experimental
%   and control participants

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

    data_cell = cell(1, 10); % Store experimental data
    data_control_cell = cell(1, 10); % Store control data
    part_list = cell(1,2) % Create list of all participant pairs processed for further analyses

    n_subj = 1; % Counter for valid subjects
    n_exp = 0; % Counter for experimental participants
    n_con = 0; % Counter for control participants
    x = 1; %switch to apply to participant counter if interaction segment is ran
    for id = 1:numOfSources
        % -----------------------------------------------------------------
        % Retrieve and set up configuration for the current participant
        % -----------------------------------------------------------------
        cfg_part = cfg; % Clone the main configuration structure
        cfg_part.currentPair = cfg_part.sources{id}; % Get the current participant pair
        group_pair = strsplit(cfg_part.currentPair, '_'); % Split the pair name to identify the group
        cfg_part.currentGroup = group_pair{1}; % Assign the group name
        
        fprintf('loading participant %s \n', cfg_part.currentPair)
        
        if contains(cfg_part.currentSegment, "laughter")
            % if the segment is "laughter", construct different file paths
            % (experimental, control), based on group
            if contains(cfg_part.currentGroup, "N")
                cfg_part.controlsrcDir = strcat(cfg_part.dataDir, cfg_part.currentGroup, '\', cfg_part.currentSegment, '\preprocessed\Coherence_ROIs\');    
                filename_control = sprintf('%s\\%s.mat',cfg_part.controlsrcDir, cfg_part.currentPair);
            else 
                cfg_part.srcDir = strcat(cfg_part.dataDir, cfg_part.currentGroup, '\', cfg_part.currentSegment, '\preprocessed\Coherence_ROIs\');
                filename = sprintf('%s\\%s.mat',cfg_part.srcDir, cfg_part.currentPair);
            end
        else
            % Construct file paths for real and RPA data
            cfg_part.srcDir = strcat(cfg_part.dataDir, cfg_part.currentGroup, '\', cfg_part.currentSegment, '\preprocessed\Coherence_ROIs');
            cfg_part.controlsrcDir = strcat(cfg_part.dataDir, cfg_part.currentGroup, '\', cfg_part.currentSegment, '\preprocessed\Coherence_ROIs_RPA\', cfg_part.currentPair);

            filename = sprintf('%s\\%s.mat',cfg_part.srcDir, cfg_part.currentPair);
            filename_control = sprintf('%s\\%s_avg.mat',cfg_part.controlsrcDir, cfg_part.currentPair);
            
            x = 0; %
        end
        
            % -----------------------------------------------------------------
            % Load coherence data
            % Process and store data for the current participant
            % -----------------------------------------------------------------
        
        try
            % Attempt to load experimental and control data
            if exist('filename', 'var')
                data = load(filename); 
                [data_cell, fqs, tps, err] = LT_CBP_load(data_cell, data, n_subj-(n_con*x), cfg_part);
                if err ~= 1
                    n_exp = n_exp + 1; %increase counter for experimental participants
                    part_list{1,1}{n_exp,1} = cfg_part.currentPair; %save name of current participant pair
                end
            end
            if exist('filename_control', 'var')
                data_control = load(filename_control);
                [data_control_cell, fqs, tps, err] = LT_CBP_load(data_control_cell, data_control, n_subj-(n_exp*x), cfg_part);
                if err ~= 1
                    n_con = n_con + 1; %increase counter for control participants
                    part_list{1,2}{n_con,1} = cfg_part.currentPair; %save name of current participant pair
                end
            end
            if err ~= 1
                n_subj = n_subj + 1; % Increment valid subject counter
            end
        catch
            % If loading fails, skip the participant and display a warning
            fprintf('no coherence file avaliable for pair %s \n', cfg_part.currentPair)
            clear filename filename_control
            continue
        end
        clear filename filename_control
    end
    cfg.fqs = fqs;
    cfg.tps = tps;
end