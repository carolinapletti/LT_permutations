% -------------------------------------------------------------------------
% Permutation tests for fNIRS wavelet transform coherence (WTC) data
% -------------------------------------------------------------------------
% This script performs statistical analysis on fNIRS WTC data for the interaction 
% phase of the Laughing Together project. It compares real participant pairs to random permutations of 
% participant data to identify time-frequency regions where real interactions 
% differ significantly from randomized data.

% The difference between real pairs and averaged random permutation pairs 
% indicates frequencies and time points where interacting participants differ 
% from fake (randomized) participant pairs.

% Steps in this script:
% 1. Load precomputed WTC data for real and randomized participant pairs.
% 2. Resample the data (time and frequency dimensions) for computational efficiency.
% 3. Perform statistical tests using permutation testing to generate null distributions.
% 4. Identify significant differences and correct for multiple comparisons.

%written by Carolina Pletti, 2025 (carolina.pletti@gmail.com)

% -------------------------------------------------------------------------
% Load all interaction_long WTC data
% -------------------------------------------------------------------------

clear all

% -------------------------------------------------------------------------
% Set statistical and analysis parameters
% -------------------------------------------------------------------------

% p-value
pval = 0.05;

% convert p-value to Z value
zval = abs(norminv(pval));

% Number of permutations for the statistical testing
n_permutes = 1000;

% -------------------------------------------------------------------------
% Create configuration structure for data loading and analysis
% -------------------------------------------------------------------------

cfg = []; % Initialize an empty structure

%names of the groups to analyze. Should correspond to subfolder names inside the raw data folder
cfg.groups = {'IC','IL','NIC','NIL'}; 

%segment of the experiment to analyze. This script for now was only tested
%on "interaction_long"
cfg.segments = {'laughter', 'interaction_long'};

% Resampling parameters
cfg.resTime = 3; % Resample time: one time point every 3
cfg.resFreq = 3; % Resample frequency: one frequency point every 3

% Columns to exclude from resampling (e.g., metadata or non-signal columns)
cfg.excCols = [1, 2, 3];


% -------------------------------------------------------------------------
% Set paths for loading and saving data
% -------------------------------------------------------------------------
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

% -------------------------------------------------------------------------
% For each segment
% ------------------------------------------------------------------------- 

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

    [all_data, all_data_control, fqs, tps, part_list] = LT_CBP_data_load(cfg);

    % all_data_real: Real participant WTC data
    % all_data_RPA: Averaged random permutation WTC data
    % fqs: Resampled frequency points
    % tps: Resampled time points

    % -------------------------------------------------------------------------
    % Perform permutation testing
    % -------------------------------------------------------------------------

    % Compute difference maps (real vs. random pairs) and permutation maps
    [diffmaps, permmaps] = LT_CBP_permutations(all_data, all_data_control, n_permutes, fqs, tps, cfg);

    % diffmaps: Difference between real and random pair data
    % permmaps: Null distributions generated from random permutations

    % -------------------------------------------------------------------------
    % Compute z- and p-values for cluster-based statistics
    % -------------------------------------------------------------------------

    % Compute z-scores, cluster sizes, and standard deviations for H0 distributions
    [means_h0, stds_h0, zmaps, max_cluster_sizes] = LT_CBP_Clusters(diffmaps, permmaps, zval, n_permutes, fqs, tps);

    % means_h0: Mean null distribution per pixel
    % stds_h0: Standard deviation of the null distribution
    % zmaps: Z-transformed maps for identifying significant regions
    % max_cluster_sizes: Maximum cluster sizes for each permutation

    % -------------------------------------------------------------------------
    % Apply cluster-based multiple comparison corrections
    % -------------------------------------------------------------------------

    % Find significant clusters using corrected thresholds
    [zmapcorr, cluster_thresh] = LT_CBP_Correction(diffmaps, max_cluster_sizes, pval, zmaps, fqs, tps);

    % zmapcorr: Z-map corrected for multiple comparisons
    % cluster_thresh: Threshold for significant clusters
    
    % save results
    zmap_filename = sprintf('%s\results\%s\zmaps', pwd, cfg.currentSegment);
    cluster_thresh_filename = sprintf('%s\results\%s\cluster_thresh', pwd, cfg.currentSegment);
    
    save(zmap_filename, zmapcorr);
    save(cluster_thresh_filename, cluster_thresh);
 
end
