function [mean_h0_cell, std_h0_cell, zmap_cell, max_cluster_sizes_cell] = LT_CBP_Clusters(diffmap_cell, permmaps_cell, cfg)
% LT_CBP_Clusters
% Performs cluster-based correction for time-frequency maps of coherence differences.
% Computes Z-maps, thresholds them based on a Z-value, and estimates cluster sizes from permutation tests.

% Inputs:
% - diffmap_cell: Cell array containing difference maps (experimental - control) for each channel.
% - permmaps_cell: Cell array containing null hypothesis maps (from permutations) for each channel.
% - zval: Z-threshold for significance (e.g., corresponding to p = 0.05).
% - cfg: Configuration structure containing analysis parameters and paths

% Outputs:
% - mean_h0_cell: Cell array of mean null hypothesis maps for each channel.
% - std_h0_cell: Cell array of standard deviation null hypothesis maps for each channel.
% - zmap_cell: Cell array of thresholded Z-maps for each channel.
% - max_cluster_sizes_cell: Cell array of maximum cluster sizes from permutation tests for each channel.

% written by Carolina Pletti (carolina.pletti@gmail.com) based on
% the script "uANTS_stats_SOL.m" by Mike X Cohen, which is part of the
% course "Neural signal processing and analysis: Zero to hero"
    
    % Step 1: Initialize output cells
    %prepare cells to store results
    mean_h0_cell = cell(1,length(diffmap_cell));  % Stores mean of permutation maps for each channel
    std_h0_cell = cell(1,length(diffmap_cell)); % Stores standard deviation of permutation maps for each channel
    zmap_cell = cell(1,length(diffmap_cell));  % Stores thresholded Z-maps for each channel
    max_cluster_sizes_cell = cell(1,length(diffmap_cell)); % Stores max cluster sizes from permutations

    % Step 2: Loop through each channel
    
    for i = 1:length(diffmap_cell)
    
        % Extract difference map and permutation maps for the current channel
        permmaps = permmaps_cell{1,i};
        diffmap = diffmap_cell{1,i};
    
        % Step 3: Compute mean and standard deviation of null hypothesis maps
        mean_h0 = squeeze(mean(permmaps, "omitnan")); % Mean of permutation maps
        mean_h0_cell{1,i} = mean_h0;
        std_h0  = squeeze(std(permmaps, "omitnan")); % Standard deviation of permutation maps
        std_h0_cell{1,i} = std_h0;

        % Step 4: Compute Z-map for the real data
        % Compute Z-scores: Z = (real_diff - mean_null) / std_null
        zmap = (diffmap-mean_h0) ./ std_h0;

        % Threshold Z-map based on the Z-value, setting subthreshold values
        % to 0
        zmap(abs(zmap)<cfg.zval) = 0;

        % Set NaN values in Z-map to 0
        zmap(isnan(zmap))=0;
        
        % Store the thresholded Z-map
        zmap_cell{1,i} = zmap;

        % Step 5: Visualization of real data and Z-map (optional)
        figure, clf
        
        % Plot the original difference map
        subplot(121)
        imagesc(cfg.tps,cfg.fqs,diffmap);
        xlabel('Time point'), ylabel('Period (sec)')
        title(sprintf('TF map of real WTC differential values for channel %d', i))
        
        % Plot the thresholded Z-map
        subplot(122)
        imagesc(cfg.tps,cfg.fqs,zmap);
        xlabel('Time point'), ylabel('Period (sec)')
        title(sprintf('Thresholded TF map of Z-values for channel %d', i))

        % Step 6: Perform cluster-based correction using permutation maps
        % Initialize a matrix to store the maximum cluster sizes for each permutation
        max_cluster_sizes = zeros(1,cfg.n_permutes);


        % Loop through each permutation map
        for permi = 1:cfg.n_permutes
    
            % Extract the current permutation map
            threshimg = squeeze(permmaps(permi,:,:));
            
            % Transform the permutation map to Z-scores
            threshimg = (threshimg-mean_h0)./std_h0;
    
            % Threshold the Z-map for the permutation map
            threshimg(abs(threshimg)<cfg.zval) = 0;
            
            % Set NaN values in Z-map to 0
            threshimg(isnan(threshimg))=0;
    
            % Identify clusters in the thresholded Z-map (requires Image Processing Toolbox)
            islands = bwconncomp(threshimg); % Find connected components (clusters)
            if numel(islands.PixelIdxList)>0
        
                % Compute the sizes of each cluster
                tempclustsizes = cellfun(@length,islands.PixelIdxList);
        
                % Store the size of the largest cluster
                max_cluster_sizes(permi) = max(tempclustsizes);
            end
        end
        % Store the maximum cluster sizes for the current channel
        max_cluster_sizes_cell{1,i} = max_cluster_sizes;
    end
end