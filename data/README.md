# Input data

The CSV files in `raw/` were supplied as attachments and are stored without changes. Their headers use FRED series identifiers. Download dates and file vintages were not supplied; these copies have not been checked against live source data.

| File | Role in this repository |
| --- | --- |
| `TB3MS.csv` | 3-month Treasury bill series; yield curve input and Vasicek short-rate proxy |
| `GS2.csv` | 2-year Treasury yield; yield curve and optional FRED PCA input |
| `GS5.csv` | 5-year Treasury yield; yield curve and optional FRED PCA input |
| `GS10.csv` | 10-year Treasury yield; yield curve and optional FRED PCA input |
| `GS30.csv` | 30-year Treasury yield; yield curve input |
| `REAINTRATREARAT10Y.csv` | Additional supplied series; not selected by the current scripts |

Keep the series filenames and column names intact so the MATLAB scripts can identify them. Missing observations in the attachments are preserved.

## Missing input

`feds200628.csv` was referenced by the supplied PCA and Vasicek scripts but was not attached. Those workflows expect GSW zero-coupon yield columns named `SVENYxx`. Place that file in `raw/` when available.
