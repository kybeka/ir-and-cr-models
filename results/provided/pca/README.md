# Shared PCA results

These three files were shared separately from the MATLAB scripts. They are stored unchanged.

| File | What is in it |
| --- | --- |
| `pca_variance.csv` | How much of the variation each of the five components explains. The shares are fractions: 0.8 means 80%. Eigenvalues measure the variation in each component. |
| `pca_factors.csv` | Values of the five components over time. |
| `pca_loadings.csv` | Weights showing how the first three components relate to each yield: 3 months, 2 years, 5 years, 10 years, and 30 years. |

These will not match the MATLAB defaults exactly. The shared results use five maturities; the script uses ten with GSW data or four with FRED data. The slope weights also have their signs flipped. A PCA pattern can be flipped without changing what it explains.

We do not have the exact code and settings that produced these files, so they are kept as examples rather than treated as checked results of this script.

When you run the MATLAB PCA script, it saves new files to `results/generated/pca/`. It does not overwrite these shared files.
