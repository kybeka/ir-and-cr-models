# Atelier MATLAB scripts

Scripts shared for the atelier, preserved as received. The descriptive filenames for PCA and Vasicek were assigned when importing pasted code; `DataAnalysis_Group5.m` retains its supplied filename. Authorship has not been independently confirmed.

| Folder | Script | Content | Required input files |
| --- | --- | --- | --- |
| `yield-curve/` | `DataAnalysis_Group5.m` | Interactive Treasury yield curve with playback and MP4 export | FRED CSVs containing `TB3MS`, `GS2`, `GS5`, `GS10`, `GS30` |
| `pca/` | `YieldCurvePCA.m` | Yield curve PCA, loadings, factors, and reconstruction | Default: `feds200628.csv` with `SVENYxx` yields; optional FRED mode uses `TB3MS`, `GS2`, `GS5`, `GS10` |
| `vasicek/` | `VasicekCalibration.m` | Short-rate estimation, yield curve calibration, and interactive Vasicek curves | `feds200628.csv`; optional `TB3MS.csv` (otherwise uses the 1Y yield as a short-rate proxy) |

## Running a script

Open MATLAB, set the Current Folder to the script's folder, place the required CSV inputs there, and run the script. Adjust its options at the top if needed. These scripts read inputs and write outputs relative to MATLAB's Current Folder.

The input datasets were not included in the supplied attachments. The scripts have not been run or validated as part of this import.

The PCA script writes `pca_monthly_matlab.csv` and `pca_loadings_matlab.csv`. The Vasicek script writes `vasicek_params_matlab.csv`. The yield curve script can save `yield_curve.mp4` from its interface. These generated files and local CSV inputs are ignored by Git.

## Import notes

- Three distinct scripts were supplied. The third pasted text is byte-for-byte identical to `DataAnalysis_Group5.m`, so only one copy is stored.
- Classroom photos were supplied as visual references for PCA plots. They are not included here.
- WhatsApp screenshots supplied context about the scripts. They are not included here because they contain personal contact details.
