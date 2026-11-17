# Data

All input files are in `raw/`. Keep their filenames and column names as they are: the scripts use them to find the right data.

## Files shared for the course

These six files are stored exactly as received. Their column names use FRED series codes. We do not know when they were downloaded, and have not compared them with the latest online data.

| File | Used for |
| --- | --- |
| `TB3MS.csv` | 3-month Treasury bill rate. Used in the yield curve chart, FRED PCA, and Vasicek model. |
| `GS2.csv` | 2-year Treasury yield. Used in the chart and FRED PCA. |
| `GS5.csv` | 5-year Treasury yield. Used in the chart and FRED PCA. |
| `GS10.csv` | 10-year Treasury yield. Used in the chart and FRED PCA. |
| `GS30.csv` | 30-year Treasury yield. Used in the chart. |
| `REAINTRATREARAT10Y.csv` | Extra data shared with the files. The current scripts do not use it. |

Any missing values have been left as they were.

## GSW data from the Federal Reserve

[`raw/feds200628.csv`](raw/feds200628.csv) was downloaded from the Federal Reserve on November 17, 2026. GSW refers to Gürkaynak, Sack, and Wright, whose research describes the yield curve estimates.

- [About the data](https://www.federalreserve.gov/data/nominal-yield-curve.htm)
- [Download the CSV](https://www.federalreserve.gov/data/yield-curve-tables/feds200628.csv)
- [Research paper](https://www.federalreserve.gov/econres/feds/the-us-treasury-yield-curve-1961-to-the-present.htm)

The file contains 17,063 daily rows, from June 14, 1961 to November 6, 2026. Columns `SVENY01` to `SVENY30` give estimated zero-coupon yields for 1 to 30 years, in percent. A zero-coupon bond pays at the end rather than making regular interest payments. These yields use continuous compounding, as the model formulas do.

The download is unchanged, including its notes, other columns, and `NA` markers for missing values. The scripts skip the notes at the top and read the yield columns.

The Fed may revise these research estimates. They are not an official statistical release, and this copy may differ from the one used in class. November 2026 is only a partial month.

### File check

SHA-256 is a file fingerprint: it lets you check that a copy is identical to this download.

```text
dfaad994aeaf232bcc3204aec4b30c0f0bbb4db410f8985d55c15390a73ff2bd
```
