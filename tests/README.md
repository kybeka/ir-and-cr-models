# Checking the MATLAB scripts

All checks passed on November 17, 2026, using MATLAB R2026a Update 5 (26.1.0.3346908).

## Run the checks yourself

In MATLAB, open the repo folder and run:

```matlab
addpath('tests');
runAtelierChecks;
```

This opens and closes chart windows, tries the controls, and saves results under `results/generated/`. It also saves the full yield curve video, which takes several minutes.

The PCA checks make temporary copies with different settings, then delete them. The last check uses FRED monthly changes. Run the original PCA script afterwards if you want its default GSW results.

## What was checked?

| Script | Checks |
| --- | --- |
| PCA | Both data sources, using levels and monthly changes. Checks that the calculations return numbers, the components explain 100% in total, and using all components recovers the original data. It also checks the component weights, their relationships, and the dates in the saved table. |
| Vasicek | Checks that the estimated parameters are valid, no months are skipped, and two ways of calculating the bond formula agree. It also checks the link between model parameters and the chart using the estimated values. |
| Yield curves | Tries the date slider, axis settings, and playback. Saves and reads back the full MP4 to check its length. |

The PCA checks also confirm that the component weights are orthogonal (at right angles) and that different components have no covariance, meaning their movements do not vary together in the sample.

## Results

| Run | Months used | Maturities | Result |
| --- | --- | --- | --- |
| PCA, GSW levels | 539 | 10 | Passed |
| PCA, GSW changes | 538 | 10 | Passed |
| PCA, FRED levels | 537 | 4 | Passed |
| PCA, FRED changes | 536 | 4 | Passed |
| Vasicek | 537 | 10 | Passed |

The video contains 537 frames at 15 frames per second: 35.8 seconds in total.

For Vasicek, the direct bond formula and a separate numerical calculation agreed within `1e-10`. The estimated speed of return to the long-run rate was about `0.14609` per year.

The model's typical yield error (RMSE) was about 57 to 166 basis points, depending on maturity. In percentage points, that is about 0.57 to 1.66. The code runs correctly, but the model does not track every yield closely.

## What these checks do not tell us

They do not prove that the source data is correct or that the shared PCA results came from these scripts.

The last GSW month is incomplete because the file ends on November 6, 2026. The scripts use the last available daily GSW value for each month; the FRED files already contain monthly values. Vasicek uses the 3-month bill rate as an estimate of the short-term rate.
