function [data_cell, fqs, tps] = LT_CBP_load(data_cell, data, subj, cfg)
% LT_CBP_load: Process and resample coherence data for fNIRS analysis
% Inputs:
%   - data_cell: Cell array to store the processed data
%   - data: Raw coherence data for the current participant
%   - subj: Index of the current participant
%   - cfg: Configuration structure containing parameters for resampling and excluded columns
% Outputs:
%   - data_cell: Updated cell array with processed coherence data
%   - fqs: List of frequency points after resampling
%   - tps: List of time points after resampling

% Carolina Pletti, 2025 (carolina.pletti@gmail.com)

    % ---------------------------------------------------------------------
    % Load coherence data from the input structure
    % ---------------------------------------------------------------------

    try
        % Try to extract the 'coherences' field from the data structure
        data = data.coherences.all{1,1};
    catch
        try
            % If 'coherences' is not available, use 'average_coherences'
            data = data.average_coherences;
        catch
            % If neither field is available, log a warning and skip
            sprintf("no data for participant at index %d", subj)
        end
    end
    
    % ---------------------------------------------------------------------
    % Process each channel and resample the data
    % ---------------------------------------------------------------------   
    chx = 1; % Channel index for the output cell array
    for chan = 1:length(data)
        % Check if the channel needs to be averaged with its equivalent pair
        ch1 = data{1,chan}(1,2); % ROI 1 index
        ch2 = data{1,chan}(1,3); % ROI 2 index
        
        if ch1 == ch2
            % If both ROIs are the same (e.g., IFGr-IFGr), use this channel's data
            data_chan = data{1,chan};
        else
            if ch2 > ch1
                % If channels are not the same, average with its equivalent
                temp_1 = data{1, chan}(:,4:end); % Data excluding the index columns
                cellsWithValue = find(cellfun(@(x) any(x(1, 2) == ch2) && any(x(1, 3) == ch1), data)); % Find matching channel
                temp_2 = data{1, cellsWithValue}(:,4:end); % Data for the matching channel
                temp_avg = mean(cat(3, temp_1, temp_2), 3, "omitnan"); % Average the two channels
                
                % Combine averaged data with the index columns
                data_chan(:,1:3) = data{1, chan}(:,1:3);
                data_chan(:,4:end) = temp_avg;
            else
                % If the channel is already included, skip it
                continue
            end
        end    
        
        % -----------------------------------------------------------------
        % Resample frequencies (rows)
        % -----------------------------------------------------------------   
        nrows = floor(size(data_chan,1) / cfg.resFreq) * cfg.resFreq; % Ensure divisibility by resFreq      
        matrix = data_chan(1:nrows, :); % Keep only the rows that fit

        % Reshape and average rows in groups of cfg.resFreq
        matrixVert = reshape(matrix, cfg.resFreq, [], size(matrix,2));
        matrixAvgVert = squeeze(mean(matrixVert, 1, "omitnan"));
        
        % Remove excluded columns if specified in the configuration
        if isfield(cfg, 'excCols')
            fqs = round(matrixAvgVert(:,1)); % Store frequency points
            remainingColumns = setdiff(1:size(matrix, 2), cfg.excCols); % Columns to keep
            matrixAvgVert = matrixAvgVert(:,remainingColumns); % Remove excluded columns
        end
        
        % -----------------------------------------------------------------
        % Resample time points (columns)
        % -----------------------------------------------------------------      
        ncols = floor(size(matrixAvgVert,2) / cfg.resTime) * cfg.resTime; % Ensure divisibility by resTime        
        matrixAvgVert = matrixAvgVert(:, 1:ncols); % Keep only the columns that fit

        % Reshape and average columns in groups of cfg.resTime
        matrixHoriz = reshape(matrixAvgVert, size(matrixAvgVert,1), cfg.resTime, []);
        chan_matrix = squeeze(mean(matrixHoriz, 2, "omitnan"));
        
        % -----------------------------------------------------------------
        % Store the processed channel data in the output cell array
        % -----------------------------------------------------------------
        data_cell{1,chx}{1,subj} = chan_matrix;
        
        % -----------------------------------------------------------------
        % Store frequency and time points for later use
        % -----------------------------------------------------------------
        if ~exist('fqs', 'var')
            % Create a list of frequency points if not already created
            fqs = 1:size(chan_matrix, 1);
        end
        % Create a list of time points
        tps = 1:size(chan_matrix, 2);
        
        % Increment the channel index
        chx = chx + 1;
    end
end