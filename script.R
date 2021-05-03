library('tidyverse')

train_x <- read.delim('Data/Train_call.txt', header=TRUE)
train_y <- read.delim('Data/Train_clinical.txt', header=TRUE, row.names = 1)
meta_data <- as.data.frame(cbind(train_x[,1], train_x[,2], train_x[,3], train_x[,4]))


#format training data
train_x <- train_x[,-c(1:4)]
train_x <- t(train_x)
train_x <- as.data.frame(train_x)

factor_y <- as.factor(t(train_y))

#plot_data:
plot(1:2834, train_x[69,])

#feature selection
rocVarImp <- filterVarImp(train_x, factor_y)
rocVarImp$sum <- apply(rocVarImp, 1, sum)

plot(1:2834, rocVarImp[,4])
hist(rocVarImp[,4], 100)

#cv feature selection
set.seed(69)
for (i in 1:10){
  testOrder <- sample(row.names(train_x))
  testSet <- train_x[testOrder,]
  testY <- train_y[testOrder,]
  
  cv_rocVarImp <- filterVarImp(testSet, testY)
}

#rfe
control <-rfeControl(functions=rfFuncs, method='cv')
test <- rfe(x = train_x, y =as.factor(t(train_y)), rfeControl = control)


#########################
genes <- read.table('../Project/BasepairToGeneMap.tsv', sep='\t', header=T)

meta_data[meta_data$V2 == 35076296, ]
genes <- as_tibble(genes)
genes_17_2185 <- genes %>%
  filter(Gene_start >= 35076296 & Gene_end <= 35282086) %>%
  filter(Chromosome == 17)
genes_12_1679 <- genes %>%
  filter(Gene_start >= 75396411 &	Gene_end <= 75693696) %>%
  filter(Chromosome == 12)

#### graph
accuracies <- read_tsv('../Project/B4TM_model_accuracies.tsv')
accuracies$summ <- as.factor(accuracies$Assessment_method)
accuracies <- accuracies %>%
  separate(Assessment_method, c('model', 'dataset'), sep='[.]') %>%
  relocate(summ)

test_accuracies <- accuracies %>%
  filter(dataset=='test')

training_accuracies <- accuracies %>%
  filter(dataset=='train')

accuracies$dataset <- factor(accuracies$dataset, ordered=T, levels=c('train', 'test'))

windows()
ggplot(data=accuracies, mapping=aes(dataset, Accuracy)) + facet_wrap(~model) +
  #geom_boxplot(position=position_dodge(1), outlier.shape = NA) +
  #geom_point(position=position_jitterdodge(dodge.width = 1)) +
  geom_boxplot(outlier.shape = NA) + geom_jitter(aes(color=dataset)) +
  ylim(0:1) + 
  labs(color='Dataset', title = 'Accuracy For Different Models') +
  xlab('Model') +
  theme_bw() +
  theme(plot.title = element_text(hjust=0.5), text=element_text(size=30)) 
  #scale_linetype_manual(name='', values='dashed') +
  scale_x_discrete(breaks=c('kNN', 'Logistic_regression', 'SVM'), labels=c('kNN', 'LR', 'SVM'))

  
  ggplot(data=accuracies, mapping=aes(model, Accuracy)) +
    geom_boxplot(aes(shape=dataset), position=position_dodge(0.85), outlier.shape = NA, show.legend=F) +
    geom_point(aes(color=dataset), position=position_jitterdodge(dodge.width = 0.85), size=2.5) +
    geom_hline(aes(yintercept=baseline_accuracy, linetype='Baseline model'), color='red', size=1.5)+
    scale_color_manual(values=c('coral', 'cornflowerblue'),labels=c('Training data', 'Test data')) +
    ylim(0:1) + 
    labs(color='Validation type', title = 'Accuracy For Different Models') +
    xlab('Model') +
    theme_bw() +
    theme(plot.title = element_text(hjust=0.5), text=element_text(size=30)) +
    scale_linetype_manual(name='', values='dashed') +
    scale_x_discrete(breaks=c('kNN', 'Logistic_regression', 'SVM'), labels=c('kNN', 'LR', 'SVM'))
  
  
 #############################
train_data_array_input <- as.tibble(read.table(file = "../Project/Data/Train_call.txt", header = T, sep = "\t"))
target_data_array <- read_tsv(file = "../Project/Data/Train_clinical.txt")
Instances <- colnames(train_data_array_input)[-c(1:4)]
feature_information <- as_tibble(t(train_data_array_input[,1:4]))
names(feature_information) <- paste(train_data_array_input$Chromosome, ".", as.character(1:dim(train_data_array_input)[1]), sep = "")
DNA_region_information <- c("Chromosome", "Start", "End", "Nclone")
rownames(feature_information) <- DNA_region_information

train_data_array <- as_tibble(t(subset(train_data_array_input, select = -c(Chromosome:Nclone))))
names(train_data_array) <- colnames(feature_information)
train_data_array <-  train_data_array %>% add_column(Instances, .before = "1.1")
train_data_array <- train_data_array %>% add_column(target_data_array$Subgroup, .before = "1.1")
train_data_array <- train_data_array %>% rename(Target = "target_data_array$Subgroup")

# Count the occurrences of every class.
target_table <- target_data_array %>% group_by(Subgroup) %>%
  tally()
# Calculate the ratios of the classes.
target_table$ratio <- target_table$n/dim(target_data_array)[1]
# Sample the classes 100 times using the ratios.
baseline_sampling_repeats <- 100
baseline_accuracy_vector <- rep(0, baseline_sampling_repeats)
for(i in 1:baseline_sampling_repeats){
  baseline_prediction <- sample(target_table$Subgroup, 
                                prob = c(target_table$ratio[1], 
                                         target_table$ratio[2], 
                                         target_table$ratio[3]),
                                size = 100,
                                replace = T)
  # Determine the fraction that is well predicted.
  baseline_accuracy_vector[i] <- sum(target_data_array$Subgroup == baseline_prediction) / dim(target_data_array)[1]
}
# Calculate the mean baseline accuracy.
baseline_accuracy <- mean(baseline_accuracy_vector)