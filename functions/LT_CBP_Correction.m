function [zmapcorr, cluster_thresh] = LT_CBP_Correction(diffmaps, max_cluster_sizes, pval, zmaps)
    
    % prepare cells to save the outcome
    zmapcorr = cell(1, length(diffmaps));
    cluster_thresh = cell(1, length(diffmaps));
    
    % show histograph of maximum cluster sizes for each channel
    
    for i = 1:length(diffmaps)
    
        max_cluster = max_cluster_sizes{1,i};
        zmap = zmaps{1,i};
        diffmap = diffmaps{1,i};

        figure, clf
        histogram(max_cluster,20)
        xlabel(sprintf('Maximum cluster sizes channel %d', i)), ylabel('Number of observations')
        title(sprintf('Expected cluster sizes under the null hypothesis for channel %d', i))


        % find cluster threshold (need image processing toolbox for this!)
        % based on p-value and null hypothesis distribution
        thresh = prctile(max_cluster,100-(100*pval));


        % plots with multiple comparisons corrections

        % now find clusters in the real thresholded zmap
        % if they are "too small" set them to zero
        islands = bwconncomp(zmap);
        for j=1:islands.NumObjects
            % if real clusters are too small, remove them by setting to zero!
            if numel(islands.PixelIdxList{j})< thresh
                zmap(islands.PixelIdxList{j})=0;
            end
        end

        % plot tresholded results
        %time points (columns)
        tps = size(diffmap,2);
        %frequencies (rows)
        fqs = size(diffmap,1);

        figure, clf
        subplot(221)
        imagesc(tps,fqs,diffmap)
        xlabel('Time (ms)'), ylabel('Period (Sec)')
        title('WTC, no thresholding') 


        subplot(222)
        imagesc(tps,fqs,diffmap)
        hold on
        contour(tps,fqs,logical(zmap),1,'linecolor','k')
        xlabel('Time (ms)'), ylabel('Period (Sec)')
        title('WTC with contour')


        subplot(223)
        imagesc(tps,fqs,zmap)
        xlabel('Time (ms)'), ylabel('Period (Sec)')
        title('z-map, thresholded')
    
        zmapcorr{1,i} = zmap;
        cluster_thresh{1,i} = thresh;
        
    end
end



