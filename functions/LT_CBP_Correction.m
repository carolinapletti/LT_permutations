function [zmapcorr, cluster_thresh] = LT_CBP_Correction(diffmaps, max_cluster_sizes, zmaps, cfg)
% LT_CBP_Correction
% Performs cluster correction on the Z-maps using the permutation-based
% null hypothesis distribution and applies a cluster threshold based on a
% specified p-value. The function visualizes the results with histograms,
% Z-maps with thresholds, and contour plots to show significant clusters.

% Inputs:
% - diffmaps: Cell array containing the difference maps for each channel.
% - max_cluster_sizes: Cell array containing the maximum cluster sizes from permutations for each channel.
% - cfg: Configuration structure containing analysis parameters and paths,
% in particular:
%       - cfg.pval: Desired p-value for significance (e.g., p = 0.05).
%       - cfg.zmaps: Cell array containing the Z-maps for each channel.
%       - cfg.fqs: Frequency points for plotting.
%       - cfg.tps: Time points for plotting.

% Outputs:
% - zmapcorr: Cell array containing the corrected (thresholded) Z-maps for each channel.
% - cluster_thresh: Cell array containing the threshold for each channel based on the p-value.

% written by Carolina Pletti (carolina.pletti@gmail.com) based on
% the script "uANTS_stats_SOL.m" by Mike X Cohen, which is part of the
% course "Neural signal processing and analysis: Zero to hero"

    % Step 1: Initialize output cells for corrected Z-maps and cluster thresholds    
    zmapcorr = cell(1, length(diffmaps)); % Store corrected Z-maps
    cluster_thresh = cell(1, length(diffmaps)); % Store cluster thresholds
    
    % Step 2: Loop through each channel to apply cluster correction
    
    for i = 1:length(diffmaps)
        % Extract relevant data for current channel
        max_cluster = max_cluster_sizes{1,i}; % Maximum cluster sizes from permutations
        zmap = zmaps{1,i}; % Z-map for current channel
        diffmap = diffmaps{1,i}; % Difference map for current channel
        
        
        % Visualize the histogram of the maximum cluster sizes for the current channel
        figure, clf
        histogram(max_cluster,20) % Plot histogram with 20 bins
        xlabel(sprintf('Maximum cluster sizes channel %d', i)), ylabel('Number of observations')
        title(sprintf('Expected cluster sizes under the null hypothesis for channel %d', i))


        % Step 3: Determine the cluster threshold using the null hypothesis distribution
        % Use the p-value to find the threshold for significant clusters.
        thresh = prctile(max_cluster,100-(100*cfg.pval)); % Calculate threshold for p-value


        % Step 4: Find and threshold real clusters based on the computed threshold
        % Identify clusters in the thresholded Z-map (requires Image Processing Toolbox)
        islands = bwconncomp(zmap); % Find connected components (clusters) in the Z-map
        
        % Loop through all identified clusters
        for j=1:islands.NumObjects
            % If a cluster is smaller than the threshold, set it to zero
            if numel(islands.PixelIdxList{j})< thresh
                zmap(islands.PixelIdxList{j})=0; % Set small clusters to zero
            end
        end


        % Step 5: Prepare for visualization (contour plots, etc.)
        % Create a grid for contour plotting
        [TPS, FQS] = meshgrid(cfg.tps, cfg.fqs); % Create meshgrid for time and frequency axes

        % Step 6: Visualization of results
        figure, clf

        % Subplot 1: Display the original difference map (no thresholding)
        subplot(221)
        imagesc(cfg.tps, cfg.fqs, diffmap) % Plot difference map
        set(gca, 'YDir', 'normal') % Flip Y-axis for correct orientation
        xlabel('Time points'), ylabel('Period (Sec)')
        title(sprintf('WTC, no thresholding, channel %d', i))

        % Subplot 2: Display the difference map with thresholded contours
        subplot(222)
        imagesc(cfg.tps, cfg.fqs, diffmap) % Plot difference map again
        set(gca, 'YDir', 'normal') % Flip Y-axis
        hold on
        contour(TPS, FQS, logical(zmap), 1, 'linecolor', 'k') % Overlay contour of significant clusters
        xlabel('Time points'), ylabel('Period (Sec)')
        title(sprintf('WTC with contour channel %d', i))

        % Subplot 3: Display the thresholded Z-map
        subplot(223)
        imagesc(cfg.tps, cfg.fqs, zmap) % Plot thresholded Z-map
        set(gca, 'YDir', 'normal') % Flip Y-axis
        xlabel('Time points'), ylabel('Period (Sec)')
        title(sprintf('Thresholded z-map channel %d', i))
        
        % Step 7: Store results
        % Store the thresholded Z-map and the computed cluster threshold for the current channel
        zmapcorr{1,i} = zmap;
        cluster_thresh{1,i} = thresh;
        
    end
end



