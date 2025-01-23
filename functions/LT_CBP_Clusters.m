function [mean_h0_cell, std_h0_cell, zmap_cell, max_cluster_sizes_cell] = LT_CBP_Clusters(diffmap_cell, permmaps_cell, zval, n_permutes)

    %prepare cells to store results
    mean_h0_cell = cell(1,length(diffmap_cell));
    std_h0_cell = cell(1,length(diffmap_cell));
    zmap_cell = cell(1,length(diffmap_cell));
    max_cluster_sizes_cell = cell(1,length(diffmap_cell));


    %for each channel

    for i = 1:length(diffmap_cell)
    
        %extract relevant data matrices
        permmaps = permmaps_cell{1,i};
        diffmap = diffmap_cell{1,i};
    
        % compute mean and standard deviation maps
        mean_h0 = squeeze(mean(permmaps, "omitnan"));
        mean_h0_cell{1,i} = mean_h0;
        std_h0  = squeeze(std(permmaps, "omitnan"));
        std_h0_cell{1,i} = std_h0;

        % now threshold real data...
        % first Z-score
        zmap = (diffmap-mean_h0) ./ std_h0;

        % threshold image at p-value, by setting subthreshold values to 0
        zmap(abs(zmap)<zval) = 0;

        % also set all NaNs to 0 in the z map
        zmap(isnan(zmap))=0;
    
        zmap_cell{1,i} = zmap;

        %%% now some plotting...

        figure, clf
        
         %time points (columns)
        tps = size(zmap,2);
        %frequencies (rows)
        fqs = size(zmap,1);
        
        subplot(121)
        imagesc(tps,fqs,diffmap);
        xlabel('Time (ms)'), ylabel('Frequency (Hz)')
        title('TF map of real power values')

        subplot(122)
        imagesc(tps,fqs,zmap);
        xlabel('Time (ms)'), ylabel('Frequency (Hz)')
        title('Thresholded TF map of Z-values')

        % initialize matrices for cluster-based correction
        max_cluster_sizes = zeros(1,n_permutes);


        % loop through permutations
        for permi = 1:n_permutes
    
            % take each permutation map, and transform to Z
            threshimg = squeeze(permmaps(permi,:,:));
            threshimg = (threshimg-mean_h0)./std_h0;
    
            % threshold image at p-value
            threshimg(abs(threshimg)<zval) = 0;
    
    
            % find clusters (need image processing toolbox for this!)
            islands = bwconncomp(threshimg);
            if numel(islands.PixelIdxList)>0
        
                % count sizes of clusters
                tempclustsizes = cellfun(@length,islands.PixelIdxList);
        
                % store size of biggest cluster
                max_cluster_sizes(permi) = max(tempclustsizes);
            end
        end
        max_cluster_sizes_cell{1,i} = max_cluster_sizes;
    end
end