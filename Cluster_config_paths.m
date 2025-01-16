function cfg = Cluster_config_paths(cfg, uni)

    %this function sets in the "cfg" variables all the paths where to find
    %the data to run LT permutation analyses, and adds all
    %necessary functions to the Matlab path
    %Adapt this function as necessary based on your own workplace!
    
    %cfg: structure containing info about the data (none of the info is
    %used in this function yet, but the function modifies the structure)
    %uni: 0 (Carolina's workplace at home) or 1 (Carolina's workplace
    %at the uni)
    
    %output:
    %the following fields are added to the cfg structure:
    %cfg.rawDir: raw data folder
    %cfg.desDir: destination folder
    
    %author: Carolina Pletti (carolina.pletti@gmail.com)

    if uni == 1

        %project folder is here:
        project_folder = 'Z:\Documents\Projects\LT_permutations\LT_permutations\';
        
        %data folder is here:
        data_folder = 'X:\hoehl\projects\LT\LT_adults\';

    else
        %project folder is here:
        project_folder = '\\fs.univie.ac.at\plettic85\Documents\Projects\LT_permutations\LT_permutations\';
        
        %data folder is here:
        data_folder = '\\share.univie.ac.at\A474\hoehl\projects\LT\LT_adults\';
    end

    %scripts are here:
    scripts_folder = [project_folder 'functions\'];
    
    %data are here:

    cfg.rawDir = [data_folder 'NIRX\Data\']; % raw data folder
    cfg.srcDir = [data_folder 'Carolina_analyses\fNIRS\data_prep\data\']; % data source folder
    
    addpath(scripts_folder); %add path with functions
    

end