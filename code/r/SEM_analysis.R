required_packages <- c("readxl","dplyr","lavaan")

installed <- rownames(installed.packages())

for(pkg in required_packages){
  if(!(pkg %in% installed)){
    install.packages(pkg, repos="https://cloud.r-project.org")
  }
}

################## SEM analyses: longitudinal analyses depression ##############
# digital traces of child maltreatment: investigating tiktok data donations and
# predicting depressive symptoms in adolescents
################################################################################

options(scipen = 999)

library(readxl)
library(dplyr)
library(lavaan)

df <- read_excel("data/demo/SEM_dummy_Data.xlsx")

if (!("Depression_t2" %in% names(df))) {
  stop("Depression_t2 is missing from the dataset.")
}

# 1. defining variables and creating reduced dataset

# outcome
outcome <- "Depression_t2"

# covariates
covariates <- c("Age_T1", "Gender_0f1m2d", "SES_SUM", "Depression_T1", "maltreatment_CTQ_T1")

# predictors included in the main model
predictors_fiml <- c(
  "Avg_searches",
  "Avg_session_length_seconds",
  "Avg_posts",
  "Parental_Control",
  "TT_sexual_solicitations",
  "No_weeks_favorites_recorded",
  "Follower",
  "Avg_chat_partners",
  "Avg_direct_messages_received",
  "Meeting_TT_strangers_offline",
  "maltreatment_CTQ_T1"
)

all_predictors <- unique(c(predictors_fiml, covariates))
all_predictors <- all_predictors[all_predictors %in% names(df)]

# converting predictor variables to numeric
for (v in predictors_fiml) {
  if (v %in% names(df)) {
    if (is.factor(df[[v]]))    df[[v]] <- as.numeric(as.character(df[[v]]))
    if (is.character(df[[v]])) df[[v]] <- suppressWarnings(as.numeric(df[[v]]))
  }
}

# 2. full-information maximum likelihood (fiml) estimation via sem

# fit main sem model with fiml and robust standard errors (mlr estimator)
formula_main <- paste0("Depression_t2 ~ ", paste(all_predictors, collapse = " + "))

fit_main <- sem(
  formula_main,
  data      = df,
  missing   = "fiml",
  estimator = "MLR"
)

# make sure results folder exists
dir.create("results", recursive = TRUE, showWarnings = FALSE)

# save console-style summary to a text file
capture.output(
  summary(fit_main, standardized = TRUE, rsquare = TRUE),
  file = "results/SEM_main_results.txt"
)

summary(fit_main, standardized = TRUE, rsquare = TRUE)
