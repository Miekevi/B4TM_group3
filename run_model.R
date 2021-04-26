# Author: Chao (Cico) Zhang
# Date: 31 Mar 2017
# Usage: Rscript run_model.R -i unlabelled_sample.txt -m model.pkl -o output.txt
# If you are using python, please use the Python script template instead.
# Set up R error handling to go to stderr
options(show.error.messages=F, error=function(){cat(geterrmessage(),file=stderr());q("no",1,F)})

# Import required libraries
# You might need to load other packages here.
suppressPackageStartupMessages({
  library('getopt')
  library('caret')
  library('tidyverse')
})

# Take in trailing command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Get options using the spec as defined by the enclosed list
# Read the options from the default: commandArgs(TRUE)
option_specification <- matrix(c(
  'input', 'i', 2, 'character',
  'model', 'm', 2, 'character',
  'output', 'o', 2, 'character'
), byrow=TRUE, ncol=4);

# Parse options
options <- getopt(option_specification);

# Start your coding
# Test command:
# Rscript run_model.R -i unlabelled_samples.txt -m lr_model.rds -o output.txt

# suggested steps
# Step 1: load the model from the model file (options$model)
# Step 2: apply the model to the input file (options$input) to do the prediction
# Step 3: write the prediction into the designated output file (options$output)

# Load the input file and the model file.
input <- read_tsv(options$input)
model <- readRDS(options$model)


# Store all the data as tibble. 
# Make an additional tibble for the DNA region information. 
# The ID is in the format <chromosome>.<#feature>
input <- as.tibble(input)
Instances <- colnames(input)[-c(1:4)]

feature_information <- as_tibble(t(input[,1:4]))
names(feature_information) <- paste(input$Chromosome, ".", as.character(1:dim(input)[1]), sep = "")
DNA_region_information <- c("Chromosome", "Start", "End", "Nclone")
rownames(feature_information) <- DNA_region_information


# Transpose the train data matrix.
# Remove the DNA region information.
# Make the DNA_IDs the new feature names.

input <- as_tibble(t(subset(input, select = -c(Chromosome:Nclone))))
names(input) <- colnames(feature_information)
input <-  input %>% add_column(Instances, .before = "1.1")

# Make predictions.
output <- data.frame("Sample" = input$Instances,
                     "Subgroup" = predict(model, input)) 

write.table(output, file = args[6], quote = TRUE, row.names = FALSE, sep = "\t")
# End your coding
message ("Done!")
