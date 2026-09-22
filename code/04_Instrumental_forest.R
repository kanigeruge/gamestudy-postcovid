# Reset all data in the memory
rm(list = ls())
Sys.time()

# log set up
log_file <- paste0(
  "C:/path/to/this/repository/figures/log_",
  format(Sys.time(), "%Y%m%d_%H%M%S"),
  ".txt"
)
options(warn = 1)
log_con <- file(log_file, open = "wt")
sink(log_con, split = TRUE)
sink(log_con, type = "message")

message("===== Script started =====")

# Get detailed R session and system information
session_info = sessionInfo()
system_info = Sys.info()
list(session_info = session_info, system_info = system_info)

message(paste("R version:", R.version$version.string))
message(paste("Platform:", system_info["sysname"], system_info["nodename"]))

# Set cores used for calculation
numthreadsset = min(12, parallel::detectCores()) 
message(paste("Threads set:", numthreadsset, "/ Detected cores:", parallel::detectCores()))

# Import libraries
message("Loading libraries...")
library(grf)
library(haven)
library(dplyr)
library(ggplot2)
message("Libraries loaded.")

# Define file path and name
file_path_import <- "C:/path/to/this/repository/data/data_grf.dta"
file_path_export <- "C:/path/to/this/repository/figures/aclate_k6_haveps5.dta"
# If you'd like to get estimate for SWLS, please specify as follows:
# file_path_export <- "C:/path/to/this/repository/figures/aclate_swls_haveps5.dta"
# If you'd like to get estimate for past-month PS5 play instead of possessing PS5, please specify as follows:
# file_path_export <- "C:/path/to/this/repository/figures/aclate_swls_play1m.dta"
# If you'd like to get estimate for an extra hour of daily video game play instead of possessing PS5, please specify as follows:
# file_path_export <- "C:/path/to/this/repository/figures/aclate_swls_playtime.dta"

message(paste("Import path:", file_path_import))
message(paste("Export path (aclate):", file_path_export))

# Import Stata file 
message("Importing dataset...")
dataset <- as.data.frame(read_dta(file_path_import))
message(paste("Dataset imported. Rows:", nrow(dataset), "/ Cols:", ncol(dataset)))
head(dataset)

# blank table for ACLATE
average_list <- data.frame(
  try = integer(),
  aclate = numeric(),
  stderr = numeric()
)

# You can specify the number of iterations (in the paper, we used estimates of iteration 1)
N <- 10
average_list <- vector("list", N)

# Define control variable names (used for both train and test)
col_controls <- c(
  "age", "gender", "married2", "married", "divorce2", "divorce",
  "havechild2", "havechild", "singlechild2", "singlechild",
  "stu1", "stu2", "stu3", "stu4", "student", "spouse", "employee",
  "self", "part", "unemployed", "guess_1", "guess_2", "guess_3",
  "guess_4", "guess_5", "pref_1", "pref_2", "pref_3", "pref_4",
  "pref_5", "pref_6", "pref_7", "pref_8", "pref_9", "pref_10",
  "pref_11", "pref_12", "pref_13", "pref_14", "pref_15", "pref_16",
  "pref_17", "pref_18", "pref_19", "pref_20", "pref_21", "pref_22",
  "pref_23", "pref_24", "pref_25", "pref_26", "pref_27", "pref_28",
  "pref_29", "pref_30", "pref_31", "pref_32", "pref_33", "pref_34",
  "pref_35", "pref_36", "pref_37", "pref_38", "pref_39", "pref_40",
  "pref_41", "pref_42", "pref_43", "pref_44", "pref_45", "pref_46",
  "pref_47", "dairi", "njoin_member", "njoin_member1", "njoin_member2",
  "njoin_member3", "njoin_member4", "njoin_member5", "njoin_shop1",
  "njoin_shop2", "njoin_shop3", "njoin_shop4", "njoin_shop6",
  "njoin_shop9", "njoin_shop10", "njoin_shop11", "njoin_shop14",
  "njoin_shop20", "job4r_1", "job4r_2", "job4r_3", "job4r_4", "job4r_5",
  "job4r_6", "job4r_7", "job4r_8", "job4r_9", "job4r_10", "job4r_11",
  "job4r_12", "job4r_13", "job4r_14", "round_6", "round_7", "round_8"
)

message(paste("Starting main loop: N =", N, "iterations"))
for(i in 1:N){
  message(paste0("--- Iteration ", i, "/", N, " ---"))
  # Set parameters
  seed.forest = 100000 + i * 100000
  
  # Define control variables
  X <- dataset %>% 
    dplyr::select(all_of(col_controls)) %>% 
    mutate(across(everything(), as.numeric))
  # Define treatment dummy
  W <- as.vector(dataset$have_ps5)
  # Define outcome variable (k6 or swls)
  # If you'd like to get estimate for other endogenous variables please specify as follows:
  # W <- as.vector(dataset$play1m_ps5)
  # W <- as.vector(dataset$averageplaytime1)
  Y <- as.vector(dataset$k6)
  # If you'd like to get estimate for SWLS, please specify as follows:
  # Y <- as.vector(dataset$swls)
  # Define instrumental variable
  Z <- as.vector(dataset$win)

  ## Step1: Orthogonalization (regression forest)
  message(paste0("  [", i, "] Fitting Y.forest..."))
  Y.forest = regression_forest(X, Y, num.trees = 2000, seed = seed.forest + 10000)
  Y.hat = predict(Y.forest)$predictions
  
  message(paste0("  [", i, "] Fitting W.forest..."))
  W.forest = regression_forest(X, W, num.trees = 2000, seed = seed.forest + 20000)
  W.hat = predict(W.forest)$predictions
  
  message(paste0("  [", i, "] Fitting Z.forest..."))
  Z.forest = regression_forest(X, Z, num.trees = 2000, seed = seed.forest + 30000)
  Z.hat = predict(Z.forest)$predictions
  
  ## Step2: First stage estimation (causal forest)
  message(paste0("  [", i, "] Fitting causal_forest (num.trees=2000)..."))
  t_first_start <- proc.time()
  
  comp.forest = causal_forest(X, W, Z,
                            Y.hat = W.hat, 
                            W.hat = Z.hat,
                            honesty = TRUE, 
                            num.trees = 2000,
                            mtry = ncol(X)/3,
                            min.node.size = 50,
                            clusters = dataset$pref,
                            num.threads = numthreadsset,
                            seed = seed.forest + 40000)
  
  t_first_elapsed <- proc.time() - t_first_start
  message(paste0("  [", i, "] causal_forest done. Elapsed: ",
                 round(t_first_elapsed["elapsed"], 1), "s"))
  
  # Predict compliance scores
  message(paste0("  [", i, "] Predicting compliance scores on all sample..."))
  comp_hat <- predict(comp.forest, estimate.variance=TRUE)
  
  comp_summary <- summary(comp_hat$predictions)
  message(paste0("  [", i, "] First stage summary: ",
                 "min=",  round(comp_summary["Min."], 4),
                 " mean=", round(comp_summary["Mean"], 4),
                 " max=",  round(comp_summary["Max."], 4)))
  
  # Detect weak instrument
  weak_instrument_flag <- 0L
  if (min(abs(comp_hat$predictions)) <= 0.01 * sd(W)) {
    warning(paste0(
      "[", i, "] WARNING: The instrument appears to be weak, with some compliance scores as ",
      "low as ", round(min(abs(comp_hat$predictions)), 4)
    ))
    weak_instrument_flag <- 1L
  }
    
  # Store compliance scores for extrapolation
  comp_vec <- comp_hat$predictions 
  
  ## Step3: Instrumental forest
  message(paste0("  [", i, "] Fitting instrumental_forest (num.trees=2000)..."))
  t_iv_start <- proc.time()
  
  iv.forest = instrumental_forest(X, Y, W, Z,
                              Y.hat = Y.hat, 
                              W.hat = W.hat, 
                              Z.hat = Z.hat,
                              honesty = TRUE, 
                              num.trees = 2000,
                              mtry = ncol(X)/3,
                              min.node.size = 50,
                              clusters = dataset$pref,
                              sample.fraction = 0.5,
                              ci.group.size = 2,
                              num.threads = numthreadsset,
                              seed=seed.forest + i)
  
  t_iv_elapsed <- proc.time() - t_iv_start
  message(paste0("  [", i, "] instrumental_forest done. Elapsed: ",
                 round(t_iv_elapsed["elapsed"], 1), "s"))
  
  # Estimate ACLATE
  aclate <- as.data.frame(average_treatment_effect(iv.forest, target.sample = "all", compliance.score = comp_vec))
  print(aclate)
  message(paste0("  [", i, "] ACLATE estimate=", round(aclate["estimate", 1], 4),
                 " se=", round(aclate["std.err", 1], 4)))

  # Save predicted value with unique ID(n)
  average_list[[i]] <- data.frame(
    try    = i,
    aclate  = aclate["estimate", 1],
    stderr = aclate["std.err", 1],
    weakflg = weak_instrument_flag,
    min_comp  = min(abs(comp_hat$predictions)),
    seed_iv = seed.forest + i 
  )
  message(paste0("--- Iteration ", i, " complete ---"))
  }

message("Main loop finished.")

# Merge all IV results
average <- do.call(rbind, average_list)
message("ACLATE summary across iterations:")
print(average)

# Export as a Stata file
message(paste("Exporting ACLATE dataset to:", file_path_export))
write_dta(average, file_path_export)

message("===== Script completed successfully =====")

sink(type = "message")
sink()
close(log_con)
