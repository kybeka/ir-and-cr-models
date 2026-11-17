# Walking through the three scripts

The scripts form a useful sequence: **look at the yield curve → describe its main patterns → try to explain it with a model.**

A yield curve shows the interest rate for lending money over different lengths of time.

The numbers below come from the MATLAB checks recorded in [the test notes](../tests/README.md). They use the data saved in this repo; different data or settings can give different results.

- [1. Yield curves](#1-yield-curves-what-did-rates-look-like)
- [2. PCA](#2-pca-can-a-few-patterns-describe-all-these-curves)
- [3. Vasicek](#3-vasicek-can-one-simple-interest-rate-model-explain-the-yields)

## 1. Yield curves: what did rates look like?

Open [InteractiveYieldCurve.m](01-yield-curves/InteractiveYieldCurve.m) in MATLAB and click **Run**.

This script takes five US Treasury rates—3 months, 2 years, 5 years, 10 years, and 30 years—and draws a curve for each month.

- Left to right: how long until the investment matures.
- Bottom to top: the annual yield, in percent.
- The slider chooses a month. **Play** shows how the curve changes over time.

For example, the last month in these files is September 2026:

| Length | Yield |
| --- | ---: |
| 3 months | 3.94% |
| 2 years | 4.65% |
| 5 years | 4.80% |
| 10 years | 4.99% |
| 30 years | 5.37% |

Here, longer-term rates are higher, so the curve slopes upwards.

The chart also shows **10Y–3M** and **10Y–2Y**. These are simply differences between rates. Here:

**10Y–3M = 4.99% − 3.94% = 1.05 percentage points.**

A negative difference means the longer-term rate is below the shorter-term rate—often called an **inverted curve**.

The table compares the selected month with a year earlier. Keep these two measures separate:

- From 4% to 5% is an increase of **1 percentage point**.
- Relative to the starting value, it is a **25% increase**.

**What this script tells you:** the shape of the curve, how rates changed, and whether short-term and long-term rates moved together.

**Try it:** move the slider to a few different years. Look for an upward slope, a flat curve, and an inverted curve. Watch what happens to the two differences shown above the chart.

## 2. PCA: can a few patterns describe all these curves?

Open [YieldCurvePCA.m](02-principal-component-analysis/YieldCurvePCA.m).

Start with the default settings: `dataSource = 'GSW'`, `useChanges = false`, and `K = 3`. Click **Run**.

Instead of following every yield separately, PCA looks for a small number of shared patterns. PCA stands for principal component analysis.

The first three usually look like this:

| Pattern | Picture it like this |
| --- | --- |
| **Level** | Lift or lower the whole curve. |
| **Slope** | Tilt the curve: one end rises relative to the other. |
| **Curvature** | Bend the curve: the middle changes relative to the ends. |

The default run uses GSW yields from 1 to 10 years. Our results were:

| Pattern | Share of variation explained |
| --- | ---: |
| Level | 98.49% |
| Slope | 1.46% |
| Curvature | 0.05% |

Together, the first three explain about **99.997%** of the variation in this sample.

That means the ten yields share a lot of information. Much of the difference between historical curves comes from rates being generally higher or lower together.

There are three main things to read in the output:

- **Loading charts:** show which yields each pattern affects. Similar weights across maturities suggest a level pattern; opposite signs at the two ends suggest a tilt.
- **Component charts over time:** show when each pattern was strong or weak. These are scores, not interest rates: a score of 5 does not mean a yield of 5%.
- **RMSE table:** shows how much is lost when the script rebuilds the yields using only three patterns. Smaller means a closer match.

For the default run, the reconstruction errors were roughly **0.6 to 2.8 basis points** across maturities. One basis point is 0.01 percentage points, so these are small differences.

**The important distinction:** this describes the data already observed. Explaining almost all historical variation does **not** mean predicting future yields almost perfectly. Also, GSW yields are already smooth curve estimates.

If you change `useChanges` to `true`, the question becomes: “What patterns explain changes from one month to the next?” In that run, the first three explained about **99.88%**.

**Try it:** run the default settings first, then set `useChanges = true` and run again. Compare the explained-variance table and the component charts. Set it back to `false` afterwards if you want the default results.

The separate [shared PCA files](../results/provided/pca/) use different settings. They are not the results behind the percentages above. The GSW data ends on November 6, 2026, so its final monthly value represents only part of November.

## 3. Vasicek: can one simple interest-rate model explain the yields?

Open [VasicekCalibration.m](03-vasicek-model/VasicekCalibration.m) and click **Run**.

Vasicek assumes the short-term rate behaves like something attached to a loose spring:

- It tends to move back towards a long-run average.
- Random shocks push it around.

The script uses the 3-month Treasury bill rate as an estimate of the short-term rate. It fits the model, then uses it to calculate yields at longer maturities. The data used here runs from January 1982 to September 2026.

The key results were:

| Result | Simple meaning |
| --- | --- |
| `rbar ≈ 2.36%` | The long-run average rate estimated by this model. |
| `kappa ≈ 0.146` | How strongly the rate is pulled towards that average. |
| Half-life ≈ **4.74 years** | How long the model expects half of a gap from that average to disappear. |

For example, a gap of 2 percentage points would shrink to 1 percentage point after about 4.74 years **on average under this fitted model**. Individual paths still move randomly.

You will also see `theta_Q ≈ 7.60%` and `lambda ≈ −0.875`. These adjust the model for pricing bonds and allowing for risk. **The 7.60% number is not a forecast of where interest rates will eventually settle.**

The charts compare:

- The average observed curve with the average model curve.
- Observed and model yields over time.
- Curves produced by different parameter choices.

The **RMSE** column measures the mismatch between model yields and observed yields. Larger errors count more heavily:

| Maturity | RMSE |
| --- | ---: |
| 1 year | About 0.57 percentage points |
| 5 years | About 1.31 percentage points |
| 10 years | About 1.66 percentage points |

Those are substantial differences. The code works, but one short-rate model does not capture all the shapes and changes in the historical yield curve.

The **Bias** column shows whether predictions tend to be too high or too low. This script calculates **observed minus predicted**, so a positive bias means the model tends to predict yields that are too low.

**Try it:** in the last window, switch from **Slides** to **Estimated from data**. Then increase `kappa` and see how the curves change. Keep in mind that editing parameters in this window changes the displayed curves; it does not rerun the fit or update the earlier error table.

PCA can describe several ways the curve changes. Vasicek tries to explain those yields using one underlying rate and a specific set of assumptions—that is a much tighter constraint.
