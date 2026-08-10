# Oceanographic-Advanced-QC
# Neighbor Test (NT) – MATLAB Example

This repository provides a compact and reproducible MATLAB example of the **Neighbor Test (NT)** applied to multiplatform oceanographic observations.

The example demonstrates how observations from two independent observing platforms can be spatially and temporally collocated and compared as part of an oceanographic quality-control workflow.

The code is intended as a methodological example accompanying the associated study rather than as the complete data-processing and quality-control system used for all platforms in the study.

---

## Example application

The example compares near-surface **salinity** observations from:

- **Platform A – FerryBox (FB):** moving observing platform, treated as the target dataset.
- **Platform B – E1-M3A buoy:** fixed observing platform, treated as the neighboring/reference dataset.

The example dataset covers observations from **October 2017 to October 2018** in the Cretan Sea, Eastern Mediterranean.

The supplied FerryBox data have been geographically reduced to provide a compact demonstration dataset. This geographical preprocessing should not be confused with the spatial collocation radius (`R`) subsequently evaluated by the Neighbor Test.

The original full platform datasets and platform-specific preprocessing routines are not distributed with this repository.

---

## Repository structure

```text
Neighbor_Test_example/
│
├── README.md
├── run_NT_example.m
│
├── functions/
│   ├── nt_find_matchups.m
│   ├── nt_calculate_metrics.m
│   ├── nt_apply_threshold.m
│   └── nt_plot_sensitivity.m
│
├── example_data/
│   └── NT_example_data.mat
│
└── output/
```

`run_NT_example.m` is the main script and can be used to reproduce the complete example.

---

## Example data

The file

```text
example_data/NT_example_data.mat
```

contains the following generic variables:

```text
timeA   observation time – Platform A
lonA    longitude – Platform A
latA    latitude – Platform A
varA    salinity – Platform A

timeB   observation time – Platform B
lonB    longitude – Platform B
latB    latitude – Platform B
varB    salinity – Platform B
```

In the supplied example:

```text
Platform A = FerryBox
Platform B = E1-M3A
```

Generic variable names are used so that the NT functions can readily be adapted to other observing-platform combinations.

The main script accepts MATLAB `datetime` arrays as well as legacy MATLAB serial datenums in the supplied example file. Numeric datenums are converted to `datetime` before the NT analysis.

---

## Neighbor Test workflow

The example follows these main steps:

1. Load observations from the two platforms.
2. Perform basic validity checks.
3. Convert observation times to MATLAB `datetime`, where required.
4. Test combinations of spatial radius (`R`) and temporal-window width (`TW`).
5. Identify valid Platform A–Platform B observation pairs.
6. Calculate matchup statistics:
   - number of matchups (`N`)
   - root-mean-square difference (`RMSD`)
   - bias
   - mean absolute error (`MAE`)
   - correlation coefficient
7. Examine the sensitivity of the comparison to the collocation criteria.
8. Apply the selected spatial and temporal criteria.
9. Calculate the observation differences.
10. Apply the fixed Neighbor Test threshold.
11. Produce diagnostic figures and save the results.

---

## Spatial and temporal collocation

For the compact GitHub example, the following spatial radii are evaluated:

```matlab
radiusDeg = [0.2 0.3 0.4 0.5 0.6];

radiusKm = 111 .* radiusDeg;
```

The reduced spatial range keeps the demonstration computationally manageable while retaining the selected spatial criterion and illustrating the sensitivity of the matchup statistics to increasing spatial radius.

The following temporal-window widths are evaluated:

```matlab
timeWindowHours = [3 6 12 24 36 48 60 72 84];
```

**TW represents the full temporal width of the accepted matching interval.**

For example,

```text
TW = 60 h
```

corresponds to a maximum temporal separation of:

```text
±30 h
```

around the target observation time.

The final configuration used for the FerryBox–E1-M3A salinity example is:

```matlab
R_selected_deg = 0.20;   % degrees
TW_selected    = 60;     % full temporal-window width, hours
```

The spatial criterion is converted to kilometres as:

```matlab
R_selected_km = 111 * R_selected_deg;
```

so that `R = 0.20°` corresponds approximately to `22.2 km`.

The selected criteria correspond to those used for this comparison in the associated study. The sensitivity analysis demonstrates how matchup availability and statistical agreement vary as the spatial and temporal collocation criteria are changed.

The final collocation criteria should therefore not be interpreted simply as the combination producing the largest number of matchups or the smallest RMSD.

---

## Matchup selection

No temporal or spatial averaging of the two observing platforms is performed during the point-to-point NT matchup procedure.

For each valid Platform A observation:

1. The geographical distance to the valid Platform B observations is calculated.
2. Platform B observations located within the prescribed spatial radius are identified.
3. Among the spatially eligible observations, the observation with the smallest absolute temporal separation from the Platform A observation is selected.
4. The pair is retained only when this temporal separation is within half of the prescribed full temporal-window width (`TW/2`).

For example, when `TW = 60 h`, the selected neighboring observation must be within **±30 h** of the corresponding target observation.

Each retained NT matchup therefore consists of one original Platform A observation paired with one original Platform B observation.

For this example, E1-M3A is a fixed platform. Consequently, its geographical position is constant, while the FerryBox position changes along its route.

---

## Spatial-distance calculation

Spatial separation is calculated using the **Haversine formula**, providing the great-circle distance between the target and neighboring observations in kilometres.

For consistency with the degree-based spatial criteria used in the associated study, candidate radii are specified in degrees and converted approximately to kilometres using:

```matlab
radiusKm = 111 .* radiusDeg;
```

The actual distance between each pair of observations is then evaluated using their geographical coordinates and the Haversine formula.

This approach accounts for the curvature of the Earth and avoids treating longitude and latitude differences as simple Cartesian distances.

---

## Difference convention

Differences are defined as:

```text
ΔS = FerryBox salinity − E1-M3A salinity
```

or generically:

```text
Difference = Target − Neighbor
```

Therefore:

- positive ΔS indicates that FerryBox salinity is higher than E1-M3A salinity;
- negative ΔS indicates that FerryBox salinity is lower than E1-M3A salinity.

The same convention is used for the bias calculation.

---

## Neighbor Test threshold

For the salinity example, the reference variability is **0.20 psu**, and the Neighbor Test threshold is defined as twice this value:

```matlab
salinity_SD = 0.20;          % psu
NT_threshold = 2 * salinity_SD;
```

resulting in:

```text
NT threshold = ±0.40 psu
```

A matchup is considered within the NT criterion when:

```text
|ΔS| ≤ 0.40 psu
```

and outside the criterion when:

```text
|ΔS| > 0.40 psu
```

The spatial collocation radius (`0.20°`), the salinity reference variability (`0.20 psu`), and the resulting NT threshold (`±0.40 psu`) are separate quantities and should not be confused.

In this implementation, the example QC flags are:

```text
1 = within NT threshold
3 = outside NT threshold / suspect
```

An observation exceeding the Neighbor Test threshold should not automatically be interpreted as an erroneous measurement. Differences between neighboring platforms may also arise from real environmental variability, vertical separation, spatial gradients, temporal separation, platform characteristics, or unresolved physical processes.

The NT is therefore intended to provide additional evidence for quality assessment rather than to replace expert interpretation.


## Running the example

Set the MATLAB working directory to the root of the repository and run:

```matlab
run_NT_example
```

The script automatically adds the `functions` directory to the MATLAB path:

```matlab
addpath('functions')
```

No modification of the supplied example data is required.

Because the sensitivity analysis repeatedly performs spatial and temporal collocation over multiple combinations of `R` and `TW`, execution time will depend on the number of observations and the computer used.

---

## Output

The script produces:

- collocation-sensitivity statistics for each spatial-radius × temporal-window combination;
- an RMSD sensitivity heatmap;
- a bias sensitivity heatmap;
- final statistics for the selected collocation configuration;
- diagnostics of the actual temporal and spatial separations of the retained matchups;
- a time series of salinity differences (`ΔS`);
- identification of observations inside and outside the NT threshold;
- a FerryBox versus E1-M3A matchup scatterplot;
- a table containing the final matched observations and associated collocation information.

Results are saved to:

```text
output/NT_example_results.mat
```

The saved output includes the sensitivity matrices, selected criteria, final NT statistics, NT flags, and final matchup table.

Numerical results are generated directly by `run_NT_example.m` and are not duplicated here to keep the repository focused on the reproducible workflow.

---

## Adapting the code to other datasets

The NT functions are written using generic Platform A and Platform B variables.

To apply the workflow to another pair of point-observation datasets, provide:

```matlab
timeA
lonA
latA
varA

timeB
lonB
latB
varB
```

and modify, where appropriate:

```matlab
radiusDeg
timeWindowHours
R_selected_deg
TW_selected
NT_threshold
```

The same point-to-point structure can therefore be adapted to comparisons involving, for example, fixed buoys, FerryBoxes, profiling floats, gliders, or other in situ observing platforms.

Comparisons between point observations and gridded products, such as satellite or model fields, may require a different spatial matchup procedure and are not demonstrated in this compact example.

---

## Requirements

- MATLAB
- Functions used in the supplied scripts must be available in the installed MATLAB release.

The example uses standard MATLAB data types including `datetime`, tables, and MAT-files.

---

## Citation

If you use this code in scientific work, please cite the associated publication:

```text
[Full citation to be added after publication]
```

When available, the DOI and full bibliographic information should be added here.

---

## Data and code scope

This repository provides a compact example designed to demonstrate the Neighbor Test methodology.

It does **not** contain the complete platform-specific processing chain used in the associated study, including all original datasets, data-ingestion routines, preprocessing procedures, quality-control stages, or analyses for every observing-platform combination.

The purpose of the repository is to provide a transparent and reusable implementation of the principal point-to-point NT workflow while keeping platform-specific research processing separate.
