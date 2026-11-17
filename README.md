# Interest Rate and Credit Risk Models

Notes, MATLAB code, and data for the atelier part of the course at USI.

## Where to start

Open the [atelier guide](atelier/README.md), pick a topic, and run its MATLAB script. The data is already included.

| Topic | What it does |
| --- | --- |
| [1. Yield curves](atelier/01-yield-curves/InteractiveYieldCurve.m) | Shows how US Treasury yields changed over time. You can play the chart and save a video. |
| [2. PCA](atelier/02-principal-component-analysis/YieldCurvePCA.m) | Finds the main patterns in how the yield curve moves. |
| [3. Vasicek](atelier/03-vasicek-model/VasicekCalibration.m) | Fits a short-rate model and compares its predicted yields with the data. |

## What is in each folder?

- `atelier/`: the three MATLAB scripts and [how to use them](atelier/README.md).
- `materials/tutorials/`: tutorial PDFs [1](materials/tutorials/tutorial-01.pdf), [2](materials/tutorials/tutorial-02.pdf), [3](materials/tutorials/tutorial-03.pdf), and [4](materials/tutorials/tutorial-04.pdf).
- `data/raw/`: the original CSV files. See [where the data came from](data/README.md).
- `results/provided/pca/`: [PCA results shared separately](results/provided/pca/README.md).
- `results/generated/`: results saved when you run the scripts. These stay on your computer.
- `tests/`: [checks that the scripts work](tests/README.md).

The scripts passed checks in MATLAB R2026a. The last month of GSW data is incomplete, and the shared PCA results use different settings from the script defaults. The guides explain both.

Keep the original data and course materials unchanged. Follow the course rules on collaboration, sources, and AI use.
