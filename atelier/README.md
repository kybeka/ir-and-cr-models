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
- **PCA:** the original default is `dataSource = 'GSW'`, using the included `data/raw/feds200628.csv`. To use the FRED data instead, set `dataSource = 'FRED'`. The supplied script's FRED settings use four maturities (3M, 2Y, 5Y, 10Y) and yield levels (`useChanges = false`).
- **Vasicek:** uses the included `feds200628.csv` and `TB3MS.csv`. The scripts intersect the available dates, so the shorter TB3MS snapshot limits the combined sample.

## Supplied results and provenance

The three supplied [PCA result files](../results/provided/pca/) are preserved separately from new script outputs. Their five maturities and settings do not match the PCA script's defaults; the generating code and configuration have not been confirmed.

File paths and output locations follow the repository layout. FRED imports select only the configured series files so that the GSW file's metadata preamble is not parsed as a FRED table. The statistical calculations and default model settings were preserved. See [MATLAB validation](../tests/README.md) for execution checks and limitations.

The GSW snapshot ends on November 6, 2026. Monthly aggregation uses the last available daily observation, so November 2026 is a partial month, labeled November 1 by MATLAB. The Vasicek sample ends in September 2026 because the supplied TB3MS data stop there. TB3MS is a monthly short-rate proxy, not a directly observed instantaneous rate.

The third pasted script was identical to the attached first-lecture file and is stored once. The screenshots and classroom photos were used to interpret the material; they are not published in the repository. Script authorship has not been independently confirmed.
