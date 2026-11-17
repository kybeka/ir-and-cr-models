# Atelier

The shared screenshots identify the three scripts as first-lecture code, PCA, and Vasicek. The classroom photos show PCA loadings and factor time series, which support the PCA classification. The numbering below provides a reading order, not a verified lecture schedule.

| Topic | MATLAB script | Purpose |
| --- | --- | --- |
| [01 - Yield curves](01-yield-curves/) | `InteractiveYieldCurve.m` | First-lecture script: Treasury yield curves, playback, comparisons, and MP4 export. Originally supplied as `DataAnalysis_Group5.m`. |
| [02 - Principal component analysis](02-principal-component-analysis/) | `YieldCurvePCA.m` | Yield curve factors, loadings, explained variance, and reconstruction. |
| [03 - Vasicek model](03-vasicek-model/) | `VasicekCalibration.m` | Short-rate estimation, yield curve calibration, and interactive model curves. |

## Running the scripts

Open a script in MATLAB and run it. Each script locates the shared [data/raw/](../data/raw/) folder using its own file location, so inputs do not need to be copied into individual topic folders. New outputs go to `results/generated/<topic>/`, which is ignored by Git.

- **Yield curves:** all five required series (`TB3MS`, `GS2`, `GS5`, `GS10`, `GS30`) are included.
- **PCA:** the original default is `dataSource = 'GSW'`, requiring `data/raw/feds200628.csv`, which has not been supplied. To use the included FRED data, set `dataSource = 'FRED'`. The supplied script's FRED settings use four maturities (3M, 2Y, 5Y, 10Y) and yield levels (`useChanges = false`).
- **Vasicek:** requires the missing `feds200628.csv` as well as the included `TB3MS.csv`. The nominal Treasury series are not a substitute for the expected GSW zero-coupon columns.

## Supplied results and provenance

The three supplied [PCA result files](../results/provided/pca/) are preserved separately from new script outputs. Their five maturities and settings do not match the PCA script's defaults; the generating code and configuration have not been confirmed.

Only file paths and output locations were changed during organization. The statistical calculations and default model settings were preserved. The scripts have not been executed as part of this reorganization.

The third pasted script was identical to the attached first-lecture file and is stored once. The screenshots and classroom photos were used to interpret the material; they are not published in the repository. Script authorship has not been independently confirmed.
