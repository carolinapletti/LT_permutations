function [diffmap_cell, permmaps_cell] = LT_CBP_permutations(data_cell, data_control_cell, part_list, cfg)
% LT_CBP_permutations
% Performs permutation tests for wavelet transform coherence data. 
% Computes difference maps between experimental and control participants
% and generates null hypothesis maps for statistical testing.

% Inputs:
% - data_cell: Cell array containing experimental participant data, organized by channel.
% - data_control_cell: Cell array containing control participant data, organized by channel.
% - cfg: Configuration structure containing analysis parameters and paths
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
        
        channelMatrix = trim_and_concat(data_cell,i); % Experimental participant data
        channelMatrix_control = trim_and_concat(data_control_cell,i); % Control participant data
        channelMatrix_all = cat(3, channelMatrix, channelMatrix_control); % Combined data
    
        % Step 4: Compute the difference map
        % Compute the mean difference between real and RPA data across participants
        diffmap = squeeze(mean(channelMatrix(:,:,:),3 , "omitnan")) - squeeze(mean(channelMatrix_control(:,:,:),3 , "omitnan"));
        % Store the difference map in the output cell
        diffmap_cell{1,i} = diffmap;
        
        % Step 5: Visualization of the data (optional)
        figure, clf
        % Plot experimental data (averaged across participants)
        subplot(221)
        imagesc(cfg.tps,cfg.fqs,squeeze(mean( channelMatrix(:,:,:),3, "omitnan" )))
        title(sprintf('Experimental Data (Averaged), channel %d', i))
        xlabel('Time points')
        ylabel('Periods (sec)')
        
        % Plot control data (either data from participants that did not interact, or averaged random pair data)
        subplot(222)
        imagesc(cfg.tps,cfg.fqs,squeeze(mean( channelMatrix_control(:,:,:),3, "omitnan" )))
        title(sprintf('Control Data (Averaged), channel %d', i))
        xlabel('Time points')
        ylabel('Periods (sec)')
        
        % Plot the difference map
        subplot(223)
        imagesc(cfg.tps,cfg.fqs,diffmap)        
        title(sprintf('Difference Map (experimental - control), channel %d', i))
        xlabel('Time points')
        ylabel('Periods (sec)')

        % Step 6: Generate null hypothesis maps via permutations
        % Initialize permutation maps (size: n_permutes x frequencies x time points)
        permmaps = zeros(cfg.n_permutes,size(channelMatrix_all,1),size(channelMatrix_all,2));

        % Loop through each permutation
        for permi = 1:cfg.n_permutes
            
            n_exp = size(part_list{1,1},1);
            % Randomly shuffle participant order across experimental and control subjects
            if contains(cfg.currentSegment, 'interaction')
                % For the interaction pahse: simply shuffle real
                % participant and RPA data
                randorder = randperm(size(channelMatrix_all,3));
            elseif contains(cfg.currentSegment, 'laughter')
                % For the video phase: control that the number of
                % participants that watched the funny videos (L) or the
                % control videos (C) remains the same in both groups after
                % randomization, to avoid introducing a confound.
                % Randomization is performed on the NI/I factor only (non
                % interaction, interaction)
                
                % Step 1: Split indexes into C and L group indexes
                IC_indices = find(contains(part_list{1,1}(:,1), 'C')); % Find all IC participants
                IL_indices = find(contains(part_list{1,1}(:,1), 'L')); % Find all IL participants
                NIC_indices = find(contains(part_list{1,2}(:,1), 'C'))+ length(part_list{1,1}); % Find all NIC participants
                NIL_indices = find(contains(part_list{1,2}(:,1), 'L'))+ length(part_list{1,1}); % Find all NIL participants
                
                C_order = [IC_indices; NIC_indices];
                L_order = [IL_indices; NIL_indices];
                % Step 3: Randomly shuffle indexes within N and I group,
                % while preserving the C and L ratio
                C_perm = C_order(randperm(length(C_order))); % Shuffle within C group
                L_perm = L_order(randperm(length(L_order))); % Shuffle within L group
                randorder = [C_perm(1:n_exp/2,:); L_perm(1:n_exp/2,:); C_perm(n_exp/2+1:end,1); L_perm(n_exp/2+1:end,1)]; 
            end
            
            temp_channelMatrix_all = channelMatrix_all(:,:,randorder);
                
            % Compute the mean difference under the null hypothesis
            % Divide shuffled data into experimental and control groups
            
            permmaps(permi,:,:) = squeeze( mean(temp_channelMatrix_all(:,:,1:n_exp),3, "omitnan") - mean(temp_channelMatrix_all(:,:,n_exp+1:end),3, "omitnan") );
        end
        
        % Store the permutation maps for this channel
        permmaps_cell{1,i} = permmaps;
    
    end
end


function channelMatrix = trim_and_concat(data, i)

        % Extract the matrices from the cell array
        matrices = data{1, i}; 
        % Find the minimum number of columns among all matrices
        minCols = min(cellfun(@(x) size(x, 2), matrices));
        % Trim each matrix to have the same number of columns
        trimmedMatrices = cellfun(@(x) x(:, 1:minCols), matrices, 'UniformOutput', false);
        % Concatenate along the third dimension
        channelMatrix = cat(3, trimmedMatrices{:});
        
end