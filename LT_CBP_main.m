% ---------------------------------------------------------------------------------------------------------
% Permutation tests for fNIRS wavelet transform coherence (WTC) data
% ---------------------------------------------------------------------------------------------------------
% This script performs statistical analysis on fNIRS WTC data for the Laughing Together project.
% For data collected during video watching, it compares participant pairs
% who interacted while watching the videos (experimental pairs) to
% participant pairs that did not interact while vatching the videos
% (control pairs)

% For data collected during free interaction, it compares real participant
% pairs (experimental pairs) to random permutations of participant data

% The goal is to identify time-frequency regions where experimental pairs 
% differ significantly from control pairs.

% Steps in this script:
% 1. Load precomputed WTC data for experimental and control participant pairs.
% 2. Resample the data (time and frequency dimensions) for computational efficiency.
% 3. Perform statistical tests using permutation testing to generate null distributions.
% 4. Identify significant differences and correct for multiple comparisons.

%written by Carolina Pletti, 2025 (carolina.pletti@gmail.com)

clear all

% ---------------------------------------------------------------------------------------------------------
% Create configuration structure for data loading and analysis
% ---------------------------------------------------------------------------------------------------------

cfg = []; % Initialize an empty structure

% p-value
cfg.pval = 0.05;

% convert p-value to Z value
cfg.zval = abs(norminv(cfg.pval));

% Number of permutations for the statistical testing
cfg.n_permutes = 1000;

%names of the groups to analyze. Should correspond to subfolder names inside the raw data folder
cfg.groups = {'IC','IL','NIC','NIL'}; 

%segments of the experiment to analyze.
cfg.segments = {'laughter', 'interaction_long'};

% Resampling parameters
cfg.resTime = 3; % Resample time: one time point every 3
cfg.resFreq = 3; % Resample frequency: one frequency point every 3

% Columns to exclude from resampling (e.g., metadata or non-signal columns)
cfg.excCols = [1, 2, 3];


% ---------------------------------------------------------------------------------------------------------
% Set paths for loading and saving data
% ---------------------------------------------------------------------------------------------------------
% Add folder paths for functions, toolboxes, and raw data.
% Modify paths in the LT_CBP_config_paths function as needed.

sel = false;

while sel == false
    fprintf('\nPlease select one option:\n');
    fprintf('[1] - Carolina''s workspace at the uni\n');
    fprintf('[2] - Carolina''s workspace at home\n');
    fprintf('[3] - None of the above\n');

    x = input('Option: ');

    switch x
        case 1
            sel = true;
            cfg = LT_CBP_config_paths(cfg, 1);
        case 2
            sel = true;
            cfg = LT_CBP_config_paths(cfg, 0);
        case 3
            sel = true;
            fprintf('please change this script and the config_path function so that the paths match with where you store data, toolboxes and scripts!');
        return;
        otherwise
            cprintf([1,0.5,0], 'Wrong input!\n');
        return
    end
end

% ---------------------------------------------------------------------------------------------------------
% For each segment
% ---------------------------------------------------------------------------------------------------------

for i = 1:length(cfg.segments)
    cfg.currentSegment = cfg.segments{i};

    % -------------------------------------------------------------------------
    % Load and preprocess the data
    % -------------------------------------------------------------------------

    % Load WTC data for all groups, both "experimental" and "control"
    % In the "interaction_long" phase, the control group is pre-created through averaged
    % random permutations of participant pairs.
    %In the "laughter" phase, the control group consists of real
    % participant pairs that watched the same videos as "experimental" pairs but did not interact during
    % video watching
    % The function will also resample the data (averaging over time and frequency).

    [all_data, all_data_control, cfg, part_list] = LT_CBP_data_load(cfg);

    % all_data: Experimental WTC data
    % all_data_control: Control WTC data
    % fqs: Resampled frequency points
    % tps: Resampled time points

    % -------------------------------------------------------------------------
    % Perform permutation testing
    % -------------------------------------------------------------------------

    % Compute difference maps (experimental vs. control pairs) and permutation maps
    [diffmaps, permmaps] = LT_CBP_permutations(all_data, all_data_control, part_list, cfg);

    % diffmaps: Difference between experimental and control pair data
    % permmaps: Null distributions generated from random permutations

    % -------------------------------------------------------------------------
    % Compute z- and p-values for cluster-based statistics
    % -------------------------------------------------------------------------

    % Compute z-scores, cluster sizes, and standard deviations for H0 distributions
    [means_h0, stds_h0, zmaps, max_cluster_sizes] = LT_CBP_Clusters(diffmaps, permmaps, cfg);

    % means_h0: Mean null distribution per pixel
    % stds_h0: Standard deviation of the null distribution
    % zmaps: Z-transformed maps for identifying significant regions
    % max_cluster_sizes: Maximum cluster sizes for each permutation

    % -------------------------------------------------------------------------
    % Apply cluster-based multiple comparison corrections
    % -------------------------------------------------------------------------

    % Find significant clusters using corrected thresholds
    [zmapcorr, cluster_thresh] = LT_CBP_Correction(diffmaps, max_cluster_sizes, zmaps, cfg);

    % zmapcorr: Z-map corrected for multiple comparisons
    % cluster_thresh: Threshold for significant clusters
    
    % save results
    zmap_filename = sprintf('%s\\results_%s_zmaps.mat', pwd, cfg.currentSegment);
    cluster_thresh_filename = sprintf('%s\\results_%s_cluster_thresh.mat', pwd, cfg.currentSegment);
    
    save(zmap_filename, 'zmapcorr');
    save(cluster_thresh_filename, 'cluster_thresh');
 
end
