# Supplied PCA reference results

These CSV attachments are preserved without modification. They were provided separately from the MATLAB scripts and have not been reproduced or independently validated.

| File | Contents |
| --- | --- |
| `pca_variance.csv` | Eigenvalues, explained variance fractions, and cumulative fractions for five components |
| `pca_factors.csv` | Dated observations for PC1 through PC5 |
| `pca_loadings.csv` | Level, slope, and curvature loadings at 3M, 2Y, 5Y, 10Y, and 30Y |

The supplied results use five maturities, while the MATLAB PCA script defaults to ten GSW maturities and its optional FRED configuration lists four. The supplied slope loadings also use the opposite sign convention to the script's normalization. These files should therefore be treated as reference outputs with unconfirmed generating settings, not verified outputs of the included script.

Fresh MATLAB outputs are written to `results/generated/pca/` and do not overwrite these files.
