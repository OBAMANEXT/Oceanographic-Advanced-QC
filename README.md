# Oceanographic-Advanced-QC
# Neighbor Test (NT) – MATLAB Example

This repository provides a compact MATLAB example of the **Neighbor Test (NT)** for quality control of multiplatform oceanographic observations.

The example accompanies an associated study on advanced quality control and demonstrates the main workflow without reproducing the complete platform-specific processing and analysis.

## Example

The example compares near-surface **salinity** observations from:

- **Platform A:** FerryBox (target)
- **Platform B:** E1-M3A buoy (neighbor)

The example dataset covers **October 2017–October 2018** in the Cretan Sea, Eastern Mediterranean. A geographically reduced subset of the observations is provided for demonstration purposes.

## Repository structure

```text
Neighbor_Test/
│
├── README.md
├── run_NT_example.m
├── functions/
│   ├── nt_find_matchups.m
│   ├── nt_calculate_metrics.m
│   ├── nt_apply_threshold.m
│   └── nt_plot_sensitivity.m
├── example_data/
│   └── NT_example_data.mat
└── output/
```

`run_NT_example.m` is the main script.

## Method

The example workflow:

1. loads and checks the two datasets;
2. evaluates different spatial (`R`) and temporal (`TW`) collocation criteria;
3. identifies point-to-point matchups;
4. calculates RMSD, bias, MAE, correlation, and number of matchups;
5. applies the selected collocation criteria;
6. calculates FerryBox–E1-M3A salinity differences;
7. applies the Neighbor Test threshold; and
8. produces diagnostic figures and saves the results.

For this compact example, the tested criteria are:

```matlab
radiusDeg = [0.2 0.3 0.4 0.5 0.6];

timeWindowHours = [3 6 12 24 36 48 60 72 84];
```

The selected configuration for this comparison is:

```matlab
R_selected_deg = 0.20;
TW_selected    = 60;
```

`TW` represents the **full temporal-window width**; therefore, `TW = 60 h` corresponds to **±30 h**.

Spatial distances are calculated using the Haversine formula. For each target observation, neighboring observations within the spatial radius are identified and the observation with the smallest absolute temporal separation is selected. No temporal or spatial averaging is performed.

## Neighbor Test threshold

Differences are calculated as:

```text
ΔS = FerryBox salinity − E1-M3A salinity
```

For salinity, the reference variability is `0.20 psu` and the NT threshold is:

```matlab
NT_threshold = 2 * 0.20;   % ±0.40 psu
```

Matchups with `|ΔS| > 0.40 psu` are flagged as suspect. Threshold exceedance does not necessarily indicate an erroneous observation, as differences may also reflect genuine environmental variability or sampling differences.

## Running the example

Set MATLAB to the repository directory and run:

```matlab
run_NT_example
```

The supplied data file contains the generic variables:

```text
timeA, lonA, latA, varA
timeB, lonB, latB, varB
```

Results are saved to:

```text
output/NT_example_results.mat
```

## Adapting the code

The functions use generic Platform A and Platform B inputs and can be adapted to other pairs of point-observation datasets by changing the input data, collocation criteria, and NT threshold.

## Requirements

- MATLAB

## Citation

If you use this code in scientific work, please cite the associated publication:

Stamataki, N., Frangoulis, C., Tsiaras, K., De Mey-Frémaux, P., Petihakis, G., and Sofianos, S. (2026). Multiplatform and multivariate quality control of physical and biogeochemical ocean observations: From quality control to environmental event identification. Frontiers in Marine Science, Ocean Observation (manuscript in preparation).

Full citation to be added after publication


## Scope

This repository provides a reproducible example of the point-to-point Neighbor Test workflow. It does not include the complete platform-specific processing chain, original full datasets, or all analyses performed in the associated study.
