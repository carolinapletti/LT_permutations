figure;
numPlots = length(data_cell); % Number of subplots needed

for i = 1:numPlots
    % Create a subplot for each matrix
    subplot(ceil(sqrt(numPlots)), ceil(sqrt(numPlots)), i); % Square grid layout
    dataMatrix = data_cell{1,i}{1,subj}; % Extract the matrix
    imagesc(dataMatrix); % Heatmap plot
    colorbar; % Add color scale
    caxis([0 1]); % Set colorbar limits from 0 to 1
    xlabel('Column Number');
    ylabel('Row Number');
    title(sprintf('Cell 1,%d', i)); % Dynamic title
    set(gca, 'YDir', 'normal'); % Correct Y-axis direction
end

sgtitle(sprintf('Heatmaps for subj %d', subj)); % Super title for the figure

figure;
numPlots = length(data_RPA_cell); % Number of subplots needed

for i = 1:numPlots
    % Create a subplot for each matrix
    subplot(ceil(sqrt(numPlots)), ceil(sqrt(numPlots)), i); % Square grid layout
    dataMatrix = data_RPA_cell{1,i}{1,subj}; % Extract the matrix
    imagesc(dataMatrix); % Heatmap plot
    colorbar; % Add color scale
    caxis([0 1]); % Set colorbar limits from 0 to 1
    xlabel('Column Number');
    ylabel('Row Number');
    title(sprintf('Cell 1,%d', i)); % Dynamic title
    set(gca, 'YDir', 'normal'); % Correct Y-axis direction
end

sgtitle(sprintf('Heatmaps for RPA subj %d', subj)); % Super title for the figure



figure;
numPlots = length(data); % Number of subplots needed

for i = 1:numPlots
    % Create a subplot for each matrix
    subplot(ceil(sqrt(numPlots)), ceil(sqrt(numPlots)), i); % Square grid layout
    dataMatrix = data{1,i}; % Extract the matrix
    imagesc(dataMatrix); % Heatmap plot
    colorbar; % Add color scale
    caxis([0 1]); % Set colorbar limits from 0 to 1
    xlabel('Column Number');
    ylabel('Row Number');
    title(sprintf('Cell 1,%d', i)); % Dynamic title
    set(gca, 'YDir', 'normal'); % Correct Y-axis direction
end

sgtitle(sprintf('Heatmaps for subj %d', subj)); % Super title for the figure

figure;
numPlots = length(data_RPA_cell); % Number of subplots needed

for i = 1:numPlots
    % Create a subplot for each matrix
    subplot(ceil(sqrt(numPlots)), ceil(sqrt(numPlots)), i); % Square grid layout
    dataMatrix = data_RPA_cell{1,i}{1,3}; % Extract the matrix
    imagesc(dataMatrix); % Heatmap plot
    colorbar; % Add color scale
    caxis([0 1]); % Set colorbar limits from 0 to 1
    xlabel('Column Number');
    ylabel('Row Number');
    title(sprintf('Cell 1,%d', i)); % Dynamic title
    set(gca, 'YDir', 'normal'); % Correct Y-axis direction
end

sgtitle('Heatmaps for data\_cell Matrices'); % Super title for the figure