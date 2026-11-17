# Input data

The six FRED CSV files in `raw/` were supplied as attachments and are stored without changes. Download dates and file vintages were not supplied; these copies have not been checked against live source data. The GSW file was downloaded separately from the Federal Reserve as documented below.

| File | Role in this repository |
| --- | --- |
| `TB3MS.csv` | 3-month Treasury bill series; yield curve input and Vasicek short-rate proxy |
| `GS2.csv` | 2-year Treasury yield; yield curve and optional FRED PCA input |
| `GS5.csv` | 5-year Treasury yield; yield curve and optional FRED PCA input |
| `GS10.csv` | 10-year Treasury yield; yield curve and optional FRED PCA input |
| `GS30.csv` | 30-year Treasury yield; yield curve input |
| `REAINTRATREARAT10Y.csv` | Additional supplied series; not selected by the current scripts |

Keep the series filenames and column names intact so the MATLAB scripts can identify them. Missing observations in the attachments are preserved.

## GSW zero-coupon yield curve data

- File: [`raw/feds200628.csv`](raw/feds200628.csv), downloaded unchanged on 2026-11-17.
- Publisher: Board of Governors of the Federal Reserve System.
- Source: [Nominal Yield Curve](https://www.federalreserve.gov/data/nominal-yield-curve.htm); [direct CSV download](https://www.federalreserve.gov/data/yield-curve-tables/feds200628.csv).
- Method: Gürkaynak, Sack, and Wright, [The U.S. Treasury Yield Curve: 1961 to the Present](https://www.federalreserve.gov/econres/feds/the-us-treasury-yield-curve-1961-to-the-present.htm).
- `SVENY01` through `SVENY30` contain continuously compounded zero-coupon yields in percent for maturities of 1 through 30 years. Other yield and parameter columns are retained.
- The original metadata preamble and `NA` missing-value markers are preserved. The MATLAB GSW import locates the `Date` header and selects the zero-coupon columns.

This is a snapshot of a Federal Reserve staff research product, subject to revisions and methodological changes. It is not an official statistical release and may differ from the vintage used in class. The original source note is retained in the CSV. See the snapshot details below for coverage and checksum.

### Snapshot details

- Coverage: 1961-06-14 through 2026-11-06.
- Daily observations: 17,063.
- SHA-256: dfaad994aeaf232bcc3204aec4b30c0f0bbb4db410f8985d55c15390a73ff2bd.
