# Interest Rate and Credit Risk Models

Course materials, MATLAB atelier scripts, input data, and supplied results for Interest Rate and Credit Risk Models at USI.

## Start here

- [Atelier guide](atelier/README.md): yield curves, principal component analysis, and the Vasicek model.
- [Tutorials](materials/tutorials/): [1](materials/tutorials/tutorial-01.pdf), [2](materials/tutorials/tutorial-02.pdf), [3](materials/tutorials/tutorial-03.pdf), [4](materials/tutorials/tutorial-04.pdf).
- [Data guide](data/README.md): six supplied CSV inputs.
- [PCA reference results](results/provided/pca/README.md): supplied factors, loadings, and explained variance.

## Folder layout

```text
atelier/
  01-yield-curves/                 InteractiveYieldCurve.m
  02-principal-component-analysis/ YieldCurvePCA.m
  03-vasicek-model/                VasicekCalibration.m
data/raw/                         Supplied CSV inputs
materials/tutorials/              Course tutorial PDFs
results/provided/pca/             Supplied PCA reference results
results/generated/                New script outputs (ignored by Git)
```

The tutorial PDFs and CSV attachments retain their supplied content. Scripts have descriptive filenames; their data and output paths follow this layout. The GSW dataset `feds200628.csv` is still missing, so the default PCA mode and Vasicek workflow require an additional input. See the atelier guide for the PCA FRED option.

## Working conventions

- Use English for code, documentation, and commit messages.
- Keep credentials and private datasets out of version control.
- Document data sources and the environment needed to reproduce each analysis.
- Follow the course requirements for collaboration, attribution, and AI disclosure. Original course materials remain attributed to their authors.
