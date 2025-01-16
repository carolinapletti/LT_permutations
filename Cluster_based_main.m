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

%% load all interaction_long data

clear all

% create empty structure that will contain all necessary parameters

cfg = [];
cfg.groups = {'IC','IL','NIC','NIL'}; %names of the groups to be analyzed. Should correspond to subfolder names inside the raw data folder below
cfg.segment = 'interaction_long'; %segment of the experiment to be analyzed. Options: laughter, interaction, interaction_long

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
            cfg = Cluster_config_paths(cfg, 1);
        case 2
            sel = true;
            cfg = Cluster_config_paths(cfg, 0)
        case 3
            sel = true;
            fprintf('please change this script and the config_path function so that the paths match with where you store data, toolboxes and scripts!');
        return;
        otherwise
            cprintf([1,0.5,0], 'Wrong input!\n');
        return
    end
end


%set the loop that run the functions through all data
%create a list of all sources, for all groups
cfg.sources = [];

for g = cfg.groups
    cfg.currentGroup = g{:};
    cfg.rawGrDir = strcat(cfg.rawDir,cfg.currentGroup,'\');

    %identify all file in the group subdirectory
    sourceList    = dir([cfg.rawGrDir, '*_*']);
    sourceList    = struct2cell(sourceList);
    sourceList    = sourceList(1,:);
    cfg.sources = [cfg.sources, sourceList];

end

numOfSources = length(cfg.sources);
cfg.dataDir = cfg.srcDir;

%prepare final matrix where to store the data
%in the end I want to have 15 different periods and 749 time points
%I am going to average through periods and time points instead of
%resampling
%prepare data cell with one data per channel. In the end I will have 10
%channels:
%1 - IFGr-IFGr, 
%2 - IFGl-IFGl,
%3 - TPJr-TPJr,
%4 - TPJl-TPJl
%5 - IFGr-IFGl (or IFGl-IFGr)
%6 - TPJr-TPJl (or TPJl-TPJr)
%7 - IFGr-TPJr (or TPJr-IFGr)
%8 - IFGl-TPJl (or TPJl-IFGl)
%9 - IFGr-TPJl (or TPJl-IFGr)
%10 - IFGl-TPJr (or TPJr-IFGl)

data_cell = cell(1, 10);
data_RPA_cell = cell(1, 10);

subj = 0;
for id = 1:numOfSources
    %retrieve unmodified cfg info
    cfg_part = cfg;
    cfg_part.currentPair = cfg_part.sources{id};
    group_pair = strsplit(cfg_part.currentPair, '_');
    cfg_part.currentGroup = group_pair{1};

    cfg_part.srcDir = strcat(cfg_part.dataDir, cfg_part.currentGroup, '\', cfg_part.segment, '\preprocessed\Coherence_ROIs');
    cfg_part.RPAsrcDir = strcat(cfg_part.dataDir, cfg_part.currentGroup, '\', cfg_part.segment, '\preprocessed\Coherence_ROIs_RPA\', cfg_part.currentPair);
    fprintf('loading participant %s \n', cfg_part.currentPair)
    filename = sprintf('%s\\%s.mat',cfg_part.srcDir, cfg_part.currentPair);
    filename_RPA = sprintf('%s\\%s_avg.mat',cfg_part.RPAsrcDir, cfg_part.currentPair);
    % load coherence data
    try
        data_real = load(filename); 
        data_RPA = load(filename_RPA); 
        subj = subj + 1;
    catch
        fprintf('no coherence file avaliable for pair %s \n', cfg_part.currentPair)
        continue
    end
    
    data_cell = Cluster_load(data_cell, data_real, subj);
    data_RPA_cell = Cluster_load(data_RPA_cell, data_RPA, subj);

end



%% statistics via permutation testing

% p-value
pval = 0.05;
    
%for each channel
for i = 1:length(data_cell)
    % Apply cellfun to extract columns from 4 onwards for each matrix in data_cell
    data_cell_trimmed = cellfun(@(x) cellfun(@(y) y(:, 4:end), x, 'UniformOutput', false), ...
                            data_cell, 'UniformOutput', false);
    data_cell_trimmed_RPA = cellfun(@(x) cellfun(@(y) y(:, 4:end), x, 'UniformOutput', false), ...
                            data_cell, 'UniformOutput', false);
    %concatenate all participant cells into one matrix
    % Convert the cell array to a 3D matrix
    channelMatrix = cat(3, data_cell_trimmed{1,i}{:});
    channelMatrix_RPA = cat(3, data_cell_trimmed_RPA{1,i}{:});
    channelMatrix_all = cat(3, channelMatrix, channelMatrix_RPA);
    
    % some visualization of the raw power data

    % for convenience, compute the difference in power between the two channels
    diffmap = squeeze(nanmean(channelMatrix(:,:,:),3 )) - squeeze(nanmean(channelMatrix_RPA(:,:,:),3 ));

    clim = [0 1300];
    xlim = [0 1]; % for plotting

    figure(2), clf
    subplot(221)
    imagesc(1248,15,squeeze(nanmean( channelMatrix(:,:,:),3 )))

    subplot(222)
    imagesc(1248,15,squeeze(nanmean( channelMatrix_RPA(:,:,:),3 )))

    subplot(223)
    imagesc(1248,15,diffmap)

    
    % convert p-value to Z value
    % if you don't have the stats toolbox, set zval=1.6449;
    zval = abs(norminv(pval));
    
    % number of permutations
    n_permutes = 1000;

    % initialize null hypothesis maps (number of permutations x numbers of
    % periods x time points
    permmaps = zeros(n_permutes,size(channelMatrix_all,1),size(channelMatrix_all,2));
    
    % generate maps under the null hypothesis
    for permi = 1:n_permutes
    
        % randomize trials, which also randomly assigns trials to channels
        randorder = randperm(size(channelMatrix_all,3));
        temp_channelMatrix_all = channelMatrix_all(:,:,randorder);
    
        % compute the "difference" map
        % what is the difference under the null hypothesis?
        npart = size(channelMatrix,3);
        permmaps(permi,:,:) = squeeze( mean(temp_channelMatrix_all(:,:,1:npart),3) - mean(temp_channelMatrix_all(:,:,npart+1:end),3) );
    end
    
end










