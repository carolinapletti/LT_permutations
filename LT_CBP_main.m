% permutation tests for fNIRS wavelet transform coherence data

% for interaction data: irrespective of group, compare all participants
% with random pairs (first calculate the random pairs)
% difference between real pairs and averaged random permutation pairs will
% tell us in which frequencies and time points there where differences
% between real interacting participants and fake participants pairs -> so
% it's a t-test, not an ANOVA!

% for video data: compare participants watching videos together with
% participants watching videos separately (since they are practically the
% same as randomly permuted pairs - same stimuli but they don't even see
% each other) -> again t-test, not ANOVA!

% for interaction data:

% load all interaction_long data

clear all

% set statistical parameters
% p-value
pval = 0.05;

% convert p-value to Z value
% if you don't have the stats toolbox, set zval=1.6449;
zval = abs(norminv(pval));

% number of permutations
n_permutes = 1000;



% create empty structure that will contain all necessary parameters to load
% the data
cfg = [];
cfg.groups = {'IC','IL','NIC','NIL'}; %names of the groups to be analyzed. Should correspond to subfolder names inside the raw data folder below
cfg.segment = 'interaction_long'; %segment of the experiment to be analyzed. Options: laughter, interaction, interaction_long

%how much should the data be resampled?
cfg.resTime = 3; %for instance, one timepoint every three
cfg.resFreq = 3; %for instance, one frequency every three

%do the data contain columns that should not be included in the resampling?
%If so, insert the numbers here
cfg.excCols = [1,2,3];


% --------------------------------------------------------------------
%set all paths for loading and saving data, add folder with functions to the path. Change paths in the config_paths
%function and following part of the script based on necessity 

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

% Load data and resample them (through averaging) so that there are less time points and less frequency points

[all_data_real, all_data_RPA] = LT_CBP_data_load(cfg);

                        
% statistics via permutation testing
[diffmaps, permmaps] = LT_CBP_permutations(all_data_real, all_data_RPA, n_permutes);

%

% compute z- and p-values based on normalized distance to H0 distributions (per pixel)

[means_h0, stds_h0, zmaps, max_cluster_sizes] = LT_CBP_Clusters(diffmaps, permmaps, zval, n_permutes);

% find clusters with cluster based multiple comparison corrections

[zmapcorr, cluster_thresh] = LT_CBP_Correction(diffmaps, max_cluster_sizes, pval, zmaps);

