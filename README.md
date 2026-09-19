# Causal effect of video gaming on mental well-being in Post-COVID Japan
Replication code and synthetic data for:
Egami, H. et al. (2026). Causal effect of video gaming on mental well-being in Post-COVID Japan. medRxiv 2026.08.12.26360262. https://doi.org/10.64898/2026.08.12.26360262

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
- R (development and testing environment used R 4.x — earlier or later versions may also work but have not been tested)
- the `.R` script requires the following packages. Install them once before running the script:
```r
  install.packages(c("grf", "haven", "dplyr", "ggplot2"))
```

## How to run
### Stata (`01_Reg_ITT.do`, `02_Reg_PSM.do`)
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

### R (`03_Instrumental_forest.R`)
1. Install the required packages listed above.
2. Before running the script, replace every occurrence of `"C:/path/to/this/repository"` in the file paths (`file_path_import`, `file_path_export`, and the log file path near the top of the script) with the full path of this repository on your machine.
3. By default the script estimates ACLATE for the K6 outcome (`k6`) and exports the result to `figures/aclate_k6.dta`. To estimate ACLATE for the SWLS outcome instead, uncomment the `Y <- as.vector(dataset$swls)` and `file_path_export <- ".../aclate_swls.dta"` lines (and comment out the corresponding K6 lines).
4. Run the script:
```r
   source("code/03_Instrumental_forest.R")
```
5. A run log is written to `figures/log_<timestamp>.txt`, and the ACLATE estimates (10 iterations with different random seeds) are written to `figures/aclate_k6.dta` (or `figures/aclate_swls.dta`).

## Data
- `data/data.dta` — synthetic dataset used by `01_Reg_ITT.do` and `02_Reg_PSM.do`.
- `data/data_grf.dta` — synthetic dataset used by `03_Instrumental_forest.R`.

## Correspondence between code and paper
| Paper element | Script | Output |
|---|---|---|
| Figure 1 | `01_Reg_ITT.do` | `figures/figure1_reg.xls` `figures/figure1_reg.txt`|
| Figure 1 | `02_Reg_PSM` | `figures/figure1_psm.xls` `figures/figure1_psm.txt`|
| Figure 2 | `03_Instrumental_forest.R` | `figures/aclate_k6.dta` (K6 outcome), `figures/aclate_swls.dta` (SWLS outcome) |

## License
Code is released under the MIT License.
The synthetic dataset is released under CC BY 4.0.

## Citation
If you use this code or data, please cite:

## Contact
Questions about the code or data can be directed to [name / email], or by opening an issue in this repository.
