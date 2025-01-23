function [data_cell, data_RPA_cell] = LT_CBP_data_load(cfg)

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
    for id = 1:20 %numOfSources
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

        data_cell = LT_CBP_load(data_cell, data_real, subj, cfg);
        data_RPA_cell = LT_CBP_load(data_RPA_cell, data_RPA, subj, cfg);

    end
end