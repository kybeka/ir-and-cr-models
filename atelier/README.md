# Using the atelier scripts

Open one of these files in MATLAB and click **Run**. Each script finds the data automatically. You do not need to move CSV files around.

## 1. Yield curves

Open [InteractiveYieldCurve.m](01-yield-curves/InteractiveYieldCurve.m).

This is the first-lecture code, originally named `DataAnalysis_Group5.m`. It plots US Treasury yields from 3 months to 30 years.

Use the slider to choose a month or press **Play**. The table compares that month with a year earlier. **Save MP4** saves a video to `results/generated/yield-curves/`.

## 2. PCA: the main ways the curve moves

Open [YieldCurvePCA.m](02-principal-component-analysis/YieldCurvePCA.m).

PCA stands for principal component analysis. It finds patterns that explain most of the differences between yield curves. The first three are usually described as:

- **Level:** yields rise or fall together.
- **Slope:** short-term and long-term yields move differently.
- **Curvature:** yields in the middle move differently from those at the ends.

The script plots these patterns and how they change over time. It also checks how well three patterns can approximate the original data.

Settings at the top of the file:

| Setting | What it means |
| --- | --- |
| `dataSource = 'GSW'` | Use the included Federal Reserve zero-coupon yields. The default uses 1-year through 10-year yields. |
| `dataSource = 'FRED'` | Use the separate Treasury CSVs instead: 3 months, 2 years, 5 years, and 10 years. |
| `useChanges = false` | Compare yield levels. Set to `true` to compare changes from one month to the next. |
| `K = 3` | Use the first three patterns to approximate the data. |

Results are saved to `results/generated/pca/`. The [shared PCA results](../results/provided/pca/) use different settings, so they will not match the defaults exactly.

## 3. Vasicek: a model for interest rates

Open [VasicekCalibration.m](03-vasicek-model/VasicekCalibration.m).

The Vasicek model assumes the short-term interest rate tends to move back towards a long-run average. The script estimates the model from the data, then compares its predicted yields with the observed yields.

The last window lets you switch between the parameters from the slides and those estimated from the data. You can also edit the values yourself. Results are saved to `results/generated/vasicek/`.

## A few things to know

- Yields are shown in percent. A move from 4% to 5% is **1 percentage point (pp)**, or **100 basis points (bp)**.
- GSW data ends on November 6, 2026. The last monthly value uses that day, so November is incomplete. MATLAB labels it November 1.
- The Vasicek data ends in September 2026 because that is where the TB3MS file stops. TB3MS is a 3-month Treasury bill rate, used here as an estimate of the short-term rate.
- All three scripts passed the [MATLAB checks](../tests/README.md). This checks that the code works; it does not mean the model fits the data perfectly.

The screenshots helped identify the scripts as first-lecture code, PCA, and Vasicek. The folder numbers give a suggested order. Photos and chat screenshots are not included. The duplicate first-lecture script is stored once; the original authors of the shared scripts have not been confirmed.
