function [diffmap_cell, permmaps_cell] = LT_CBP_permutations(data_cell, data_control_cell, n_permutes, fqs, tps, cfg)
% LT_CBP_permutations
% Performs permutation tests for wavelet transform coherence data. 
% Computes difference maps between real and random participant averages 
% and generates null hypothesis maps for statistical testing.

% Inputs:
% - data_cell: Cell array containing real participant data, organized by channel.
% - data_RPA_cell: Cell array containing randomly paired average data, organized by channel.
% - n_permutes: Number of permutations for null hypothesis testing.
% - fqs: Frequency points.
% - tps: Time points.
%
% Outputs:
% - diffmap_cell: Cell array containing difference maps for each channel.
% - permmaps_cell: Cell array containing null hypothesis maps for each channel.

% written by Carolina Pletti (carolina.pletti@gmail.com)
% the permutation testing part is taken from the script "uANTS_stats_SOL.m"
% by Mike X Cohen, which is part of the course "Neural signal processing
% and analysis: Zero to hero"
    
    % steps that are specific per condition
    
    if contains(cfg.currentSegment, 'interaction')
        % Step 1: Synchronize NaN values between real and RPA data
        % Ensure that NaN values in data_cell are also present in data_RPA_cell 
        for j = 1:length(data_cell)
            for k = 1:length(data_cell{1,1})
                % Create a mask of NaN positions in the real data
                nanMask = isnan(data_cell{j}{k}); % Create a mask of NaN positions
                % Apply the mask to the corresponding RPA data
                data_control_cell{j}{k}(nanMask) = NaN;
            end
        end
    end
        
    % Step 2: Initialize output cell arrays
    % Cell array for difference maps (real - RPA) for each channel
    diffmap_cell = cell(1, length(data_cell));
    % Cell array for permutation-based null hypothesis maps for each channel
    permmaps_cell = cell(1, length(data_cell));


    % Step 3: Loop through each channel
    for i = 1:length(data_cell)   
        % Concatenate all participant matrices into a 3D matrix
        channelMatrix = cat(3, data_cell{1,i}{:}); % Real participant data
        channelMatrix_control = cat(3, data_control_cell{1,i}{:}); % RPA (random pairs) data
        channelMatrix_all = cat(3, channelMatrix, channelMatrix_control); % Combined data
    
        % Step 4: Compute the difference map
        % Compute the mean difference between real and RPA data across participants
        diffmap = squeeze(mean(channelMatrix(:,:,:),3 , "omitnan")) - squeeze(mean(channelMatrix_control(:,:,:),3 , "omitnan"));
        % Store the difference map in the output cell
        diffmap_cell{1,i} = diffmap;
        
        % Step 5: Visualization of the data (optional)
        figure, clf
        % Plot real data (averaged across participants)
        subplot(221)
        imagesc(tps,fqs,squeeze(mean( channelMatrix(:,:,:),3, "omitnan" )))
        title(sprintf('Experimental Data (Averaged), channel %d', i))
        xlabel('Time points')
        ylabel('Periods (sec)')
        
        % Plot control data (either data from participants that did not interact, or averaged random pair data)
        subplot(222)
        imagesc(tps,fqs,squeeze(mean( channelMatrix_control(:,:,:),3, "omitnan" )))
        title(sprintf('Control Data (Averaged), channel %d', i))
        xlabel('Time points')
        ylabel('Periods (sec)')
        
        % Plot the difference map
        subplot(223)
        imagesc(tps,fqs,diffmap)        
        title(sprintf('Difference Map (experimental - control), channel %d', i))
        xlabel('Time points')
        ylabel('Periods (sec)')

        % Step 6: Generate null hypothesis maps via permutations
        % Initialize permutation maps (size: n_permutes x frequencies x time points)
        permmaps = zeros(n_permutes,size(channelMatrix_all,1),size(channelMatrix_all,2));

        % Loop through each permutation
        for permi = 1:n_permutes

            % Randomly shuffle participant order across real and RPA
            % subjects
            if contains(cfg.currentSegment, 'interaction')
                randorder = randperm(size(channelMatrix_all,3));
            elseif contains(cfg.currentSegment, 'laughter')
                order = [zeros(length(all_data_control{1,1}),1); ones(length(all_data{1,1}),1)];
                temp = randperm(size(order,1));
                randorder = order(temp, 1);
            end
            temp_channelMatrix_all = channelMatrix_all(:,:,randorder);
                
            % Compute the mean difference under the null hypothesis
            % Divide shuffled data into real and RPA groups
            npart = size(channelMatrix,3);
            permmaps(permi,:,:) = squeeze( mean(temp_channelMatrix_all(:,:,1:npart),3, "omitnan") - mean(temp_channelMatrix_all(:,:,npart+1:end),3, "omitnan") );
        end
        
        % Store the permutation maps for this channel
        permmaps_cell{1,i} = permmaps;
    
    end
end