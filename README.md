# Nature Code Submission Package

This repository is a reproducible submission package for the manuscript code for the paper
Digital Traces of Child Maltreatment: Investigating TikTok Data Donations and Predicting Depressive Symptoms in Adolescents

The code is released under the MIT License.

##  repo structure

## 📁 Project Structure
   Directory/File                | Description                          |
 |-------------------------------|--------------------------------------|
 | **project/**                  | Root directory                       |
 | ├── README.md                 | Project overview and instructions    |
 | ├── LICENSE                   | License information                  |
 | ├── **code/**                 | Main code directory                  |
 | │   ├── run_analysis.sh       | Shell script for analysis            |
 | │   ├── **python/**           | Python scripts and notebooks         |
 | │   │   ├── notebook.ipynb    | Jupyter notebook                     |
 | │   │   └── requirements.txt  | Python dependencies                  |
 | │   └── **r/**                | R scripts                            |
 | │       ├── sem_analysis.R    | R script for SEM analysis            |
 | │       └── r_requirements.txt| R dependencies                       |
 | ├── **data/**                 | Data directory                       |
 | │   └── **demo/**             | Sample data files                    |
 | │       ├── dummy_raw_dataset.xlsx     | Raw dataset                          |
 | │       ├── dummy_transformed_dataset.xlsx | Transformed dataset          |
 | │       └── SEM_dummy_data.xlsx        | SEM-specific data                    |
 | └── **docs/**                 | Documentation                        |
 |     └── code_submission_checklist_notes.txt | Notes for code submission     |

## contents

- `code/run_analysis.sh` — orchestrates the analysis pipeline
- `code/python/notebook.ipynb` — main python notebook
- `code/python/requirements.txt` — python package list for the notebook
- `code/python/pip_freeze.txt` — saved python package list
- `code/r/sem_analysis.R` — r sem analysis script
- `code/r/r_requirements.txt` — r package list
- `data/demo/` — anonymized/synthetic demo data for review
- `docs/code_submission_checklist_notes.txt` — fill-in notes for the nature checklist

## demo settings

For the review/demo version:

- the python notebook uses `optuna` with `n_trials = 5` instead of `20`
- the demo run uses only `10` participants for speed
- all bundled demo data are anonymized or synthetically generated because the study data are sensitive and confidential

## system requirements

Tested with Python version 3.10.11 and R version 4.5.1

### python
The notebook uses common scientific-python packages listed in `code/python/requirements.txt`, including:

- numpy
- pandas
- scikit-learn
- optuna
- xgboost
- interpret
- shap
- torch
- seaborn
- matplotlib
- joblib
- openpyxl
- jupyter / nbconvert

### r
The r script uses:

- readxl
- dplyr
- lavaan

## installation

### local run
1. install the required python and r packages in your environment
2. keep the repository structure exactly as shown
3. place the demo xlsx files in `data/demo/`
4. run the analysis from the repository root

### code ocean
Import the repository as a capsule, verify the environment, and run the notebook/script from the repository root.

## run

From the repository root:

```bash
bash code/run_analysis.sh
```

The script will:

1. run the python notebook with `jupyter nbconvert`
2. run the r sem script with `Rscript`

## outputs

Expected outputs include:

- `data/demo/dummy_transformed_dataset.xlsx`
- `code/python/pip_freeze.txt`

## data note

The real participant-level dataset is sensitive and confidential and is not included here. The demo files in `data/demo/` are anonymized/synthetic stand-ins that preserve the column structure needed to run the code.
