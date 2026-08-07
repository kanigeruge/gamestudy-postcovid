# Causal effect of video gaming on mental well-being in Post-COVID Japan
Replication code and synthetic data for:
Egami, H. et al. (2026). Causal effect of video gaming on mental well-being in Post-COVID Japan. [Journal name]. [DOI or link]

## Overview
This repository contains the code and a synthetic dataset used to reproduce the main analyses in the paper. The synthetic dataset was generated using the SDV (Synthetic Data Vault) Python library and approximates the structure and variable relationships of the original dataset, but does not contain any real observations and cannot be used to recover information about actual survey respondents.

> **Note on data:** The original data used in the paper cannot be shared publicly due to participant confidentiality. The synthetic dataset provided here is intended to demonstrate that the code runs correctly and produces outputs of the expected form; **The SDV-based synthesis does not perfectly reproduce all variable relationships present in the original data, so results generated from the synthetic data will not match the results reported in the paper.**

## Repository structure
```
.
├── code/
│   ├── 01_Reg_ITT.do       # Main analysis (ITT estimation in Figure 1)
│   ├── 02_Reg_PSM.do       # Main analysis (PSM estimation in Figure 1)
│   └── 03_Reg_IV.do        # Main analysis (IV estimation in Figure 2) 
├── data/
│   └── data.dta            # Synthetic dataset (see Data section below)
├── figures/                # Generated figures and tables
├── LICENSE
└── README.md
```

## Requirements
- [Stata X.X.X] (development and testing environment — the code has been verified to run in this version; earlier or later versions may also work but have not been tested)
- Required packages:

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
   do "code/03_Reg_IV.do"
```
4. Outputs (figures and tables) will be written to `figures/`.

## Data
File: data/data.dta

## Correspondence between code and paper
| Paper element | Script | Output |
|---|---|---|
| Figure 1 | `01_Reg_ITT.do` | `figures/figure1_reg.xls` `figures/figure1_reg.txt`|
| Figure 1 | `02_Reg_PSM` | `figures/figure1_psm.xls` `figures/figure1_psm.txt`|
| Figure 2 | `03_Reg_IV.do` | `figures/figure1.png` |

## License
Code is released under the MIT License.
The synthetic dataset is released under CC BY 4.0.

## Citation
If you use this code or data, please cite:

## Contact
Questions about the code or data can be directed to [name / email], or by opening an issue in this repository.
