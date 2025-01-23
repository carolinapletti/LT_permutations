function [diffmap_cell, permmaps_cell] = LT_CBP_permutations(data_cell, data_RPA_cell, n_permutes)
    
    %find cells with NaNs in data_cell and make sure that the same cells have NaNs also in data_RPA_cell                    
    % Loop through the outer cells
    for j = 1:length(data_cell)
        % Loop through the inner cells
        for k = 1:length(data_cell{1,1})
            % Check if the corresponding matrix in cell_one contains NaN
            nanMask = isnan(data_cell{j}{k}); % Create a mask of NaN positions

            % Update cell_two at the same position using the mask
            data_RPA_cell{j}{k}(nanMask) = NaN;
        end
    end

    %create cell of differece maps, one per channel
    diffmap_cell = cell(1, length(data_cell));

    %create cell of permutations data
    permmaps_cell = cell(1, length(data_cell));



    %for each channel
    for i = 1:length(data_cell)
    
        %concatenate all participant cells into one matrix
        % Convert the cell array to a 3D matrix
        channelMatrix = cat(3, data_cell{1,i}{:});
        channelMatrix_RPA = cat(3, data_RPA_cell{1,i}{:});
        channelMatrix_all = cat(3, channelMatrix, channelMatrix_RPA);
    
        % some visualization of the raw power data

        % for convenience, compute the difference in power between the two channels
        diffmap = squeeze(mean(channelMatrix(:,:,:),3 , "omitnan")) - squeeze(mean(channelMatrix_RPA(:,:,:),3 , "omitnan"));
        diffmap_cell{1,i} = diffmap;
    
        clim = [0 1300];
        xlim = [0 1]; % for plotting
        
        %time points (columns)
        tps = size(diffmap,2);
        %frequencies (rows)
        fqs = size(diffmap,1);

        figure, clf
        subplot(221)
        imagesc(tps,fqs,squeeze(mean( channelMatrix(:,:,:),3, "omitnan" )))

        subplot(222)
        imagesc(tps,fqs,squeeze(mean( channelMatrix_RPA(:,:,:),3, "omitnan" )))

        subplot(223)
        imagesc(tps,fqs,diffmap)


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
            permmaps(permi,:,:) = squeeze( mean(temp_channelMatrix_all(:,:,1:npart),3, "omitnan") - mean(temp_channelMatrix_all(:,:,npart+1:end),3, "omitnan") );
        end

        permmaps_cell{1,i} = permmaps;
    
    end
end