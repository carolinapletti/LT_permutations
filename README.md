# LT_CBP (Laughing Together Cluster-Based Permutation Test)


## Overview
The `LT_CBP` toolbox implements a time-frequency cluster-based permutation test for analyzing time-frequency wavelet transform coherence (WTC) data, calculated on functional near infrared spectroscopy data collected from two participants simultaneously. The toolbox was implemented specifically to analyze the data of the Laughing Toghether project. If you plan to use it for other project, you will need to modify all project-specific parts (especially in the functions about data preprocessing). The toolbox performs clustering, permutation-based null hypothesis testing, and thresholding of statistical maps to correct for multiple comparisons.
Permutation tests of wavelet transform coherence data for the laughing together project

Information on how the WTC data were obtained can be found [here](https://github.com/carolinapletti/LaughingTogether)

## Features

- **Data Preprocessing**: Handles WTC data, resampling of frequency and time points, and averaging across similar channels.
- **Permutation Testing**: Performs a cluster-based permutation test to generate null distributions and assess statistical significance.
- **Cluster Correction**: Implements a cluster thresholding method based on permutation-based null distributions and p-values.
- **Visualization**: Generates time-frequency maps, z-maps, and contour plots with significant clusters to aid in the interpretation of results.
  
## Installation

### Requirements

- MATLAB (R2019b or later recommended)
- Image Processing Toolbox (for clustering)
- Signal Processing Toolbox (for data manipulation)

### Setup

1. Clone the repository to your local machine:

   ```bash
   git clone https://github.com/your-username/LT_CBP.git

2. Add the project folder to your MATLAB path:

   ```matlab
   addpath(genpath('path_to_LT_CBP'))

3. Make sure that the required MATLAB toolboxes (Image Processing Toolbox, Signal Processing Toolbox) are installed.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Thanks to [Mike X Cohen](https://github.com/mikexcohen): The functions for permutation testing and cluster-based multiple comparison correction in this toolbox are taken from [Mike X Cohen's Course "Neural signal processing and analysis: Zero to hero" ](https://www.udemy.com/course/solved-challenges-ants/learn/lecture/17323468?start=0#overview)
- This project was developed as part of the [Marie Skłodowska-Curie Fellowship "Laughing Together"](https://entw-psy.univie.ac.at/en/research/current-projects/laughing-together/) at the [WieKi Lab, Faculty of Psychology, University of Vienna, Austria](https://psychologie.univie.ac.at/en/research/labs/wieki-lab-wiener-kinderstudien/).




## Running the Scripts

1. Prepare your data files in the appropriate directory structure:

- Your data should be organized by groups and preprocessed according to the project's requirements. The `rawDir` should contain the subdirectories for each group, and within each group's directory, the data should be placed following the expected naming convention.

2. Modify the `cfg` structure to match your data. Specifically:

- Set the `rawDir` to the directory containing your raw WTC data.
- Define the `groups` that correspond to your data groups (e.g., different experimental conditions).
- Set any other parameters as necessary, including `segment` and `srcDir`.

3. Run the main script, which calls the functions in sequence:

- `LT_CBP_data_load(cfg)` to load your data.
- `LT_CBP_permutations(data_cell, data_RPA_cell, n_permutes, fqs, tps)` to perform the permutation tests.
- `LT_CBP_Clusters(diffmap_cell, permmaps_cell, zval, n_permutes, fqs, tps)` to compute cluster statistics.
- `LT_CBP_Correction(diffmaps, max_cluster_sizes, pval, zmaps, fqs, tps)` to apply multiple comparison corrections.

4. Check the output files and figures generated by each step for results.

## Functions

### `LT_CBP_load` & `LT_CBP_data_load`

These functions load and preprocesses the time-frequency WTC data, averaging across channels when necessary and resampling the frequency and time points according to the provided configuration (`cfg`).

### `LT_CBP_permutations`

This function performs a permutation test to generate null hypothesis distributions and computes the difference maps between real data and randomized data.

### `LT_CBP_Clusters`

This function computes Z-scores and applies a threshold to the difference maps. It uses the permutation-based null hypothesis distributions to correct for multiple comparisons and identifies significant clusters.

### `LT_CBP_Correction`

This function applies cluster-based correction to the Z-maps based on the permutation-based null hypothesis distribution and applies a cluster threshold using a specified p-value. It visualizes the corrected maps and computes the cluster thresholds.
