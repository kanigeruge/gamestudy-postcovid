# Causal effect of video gaming on mental well-being in Post-COVID Japan
Replication code and synthetic data for:
Egami, H. et al. (2026). Causal effect of video gaming on mental well-being in Post-COVID Japan. [Journal name]. [DOI or link]

## Overview
This repository contains the code and a synthetic dataset to support verification of the analytic code and transparency. The synthetic dataset was generated using the SDV (Synthetic Data Vault) Python library.

## Repository structure
```
.
├── code/
│   ├── 01_Reg_ITT.do       # Main analysis (ITT estimation in Figure 1)
│   └── 02_Reg_PSM.do       # Main analysis (PSM estimation in Figure 1)
│   └── 03_Instrumental_forest.R  # Machine learning analysis (ACLATE estimation in Figure 2)
├── data/
│   ├── data.dta            # Synthetic dataset for ITT and PSM (see Data section below)
│   └── data_grf.dta        # Synthetic dataset for machine learning (see Data section below)
├── figures/                # Generated figures and tables
├── LICENSE
└── README.md
```

## Requirements
- Stata 16.1 (development and testing environment — the code has been verified to run in this version; earlier or later versions may also work but have not been tested)
- the `.do` files require the following user-written packages. Install them once before running the scripts:
```stata
  ssc install reghdfe
  ssc install ftools   // dependency of reghdfe
  ssc install outreg2
```

## How to run
All commands below assume your working directory is the repository root
(i.e., the folder created by `git clone`, containing `code/`, `data/`, etc.)

1. Clone this repository.
2. Install the required packages listed above.
3. before running any `.do` file, open each code and set the `work` global at the top to the full path of this repository on your machine:
```stata
   global work "C:/path/to/this/repository"
```
All file paths in the `.do` files are written relative to `$work` (e.g., `use "$work/data/data.dta"`), so this is the only line that needs to be edited before running the scripts.

4. Run the scripts in `code/` in numbered order:
```
   do "code/01_Reg_ITT.do"
   do "code/02_Reg_PSM.do"
```
5. Outputs (figures and tables) will be written to `figures/`.

## Data
File: data/data.dta

## Correspondence between code and paper
| Paper element | Script | Output |
|---|---|---|
| Figure 1 | `01_Reg_ITT.do` | `figures/figure1_reg.xls` `figures/figure1_reg.txt`|
| Figure 1 | `02_Reg_PSM` | `figures/figure1_psm.xls` `figures/figure1_psm.txt`|

## License
Code is released under the MIT License.
The synthetic dataset is released under CC BY 4.0.

## Citation
If you use this code or data, please cite:

## Contact
Questions about the code or data can be directed to [name / email], or by opening an issue in this repository.
