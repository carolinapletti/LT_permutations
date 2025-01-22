function data_cell = Cluster_load(data_cell, data, subj)

    try
        data = data.coherences.all{1,1};
    catch
        try
            data = data.average_coherences;
        catch
            sprintf("no data for participant at index %d", subj)
        end
    end
    
    %average data of analogous channel (e.g., IFGr-TPJr and TPJr-IFGr)
    %extract data from each channel and start putting them in the
    %channel matrixes inside the "all_data" cell. For each channel, there is a 4d matrix with
    %size: "group" (real or RPA) x periods x time points x participants
    %so, for each participant, there is a 2d matrix with periods x time
    %points
    
    chx = 1;
    for chan = 1:length(data)
        %check which channels are contained in the cell and if it needs to be averaged with another cell
        ch1 = data{1,chan}(1,2);
        ch2 = data{1,chan}(1,3);
        if ch1 == ch2
            %average this channel combination with the equivalent
            %combination (e.g. IFGr-IFGl with IFGl-IFGr)
            data_chan = data{1,chan};
        else
            if ch2 > ch1
                temp_1 = data{1, chan}(:,4:end);
                cellsWithValue = find(cellfun(@(x) any(x(1, 2) == ch2) && any(x(1, 3) == ch1), data));
                temp_2 = data{1, cellsWithValue}(:,4:end);
                temp_avg = mean(cat(3, temp_1, temp_2), 3, "omitnan");
                data_chan(:,1:3) = data{1, chan}(:,1:3);
                data_chan(:,4:end) = temp_avg;
            else
                continue
            end
        end        
        % Step 1: Vertically average every three rows
        % Remove extra rows to make the size divisible by 3
            
        matrix = data_chan(1:45, :); % Now it has 45 rows, divisible by 3

        % Reshape and average vertically
        matrixVert = reshape(matrix, 3, [], size(matrix,2)); % Split into groups of 3 rows
        matrixAvgVert = squeeze(mean(matrixVert, 1, "omitnan")); % Average across each group of 3 rows
        indexes = matrixAvgVert(:,1:3);

        % Step 2: Horizontally average every three columns
        % Remove extra columns to make the size divisible by 3
        matrixAvgVert = matrixAvgVert(:, 4:3747); % Now it has 3747 columns, divisible by 3

        % Reshape and average horizontally
        matrixHoriz = reshape(matrixAvgVert, size(matrixAvgVert,1), 3, []);
        chan_matrix = squeeze(mean(matrixHoriz, 2, "omitnan")); % Average across each group of 3 columns
        
        chan_matrix = [indexes, chan_matrix];
        
        data_cell{1,chx}{1,subj} = chan_matrix;
        
        chx = chx + 1;
    end
end