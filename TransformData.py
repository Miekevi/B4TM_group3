import numpy as np

train_data = open('files\Train_call.txt', 'r').read()
targets = open('files\Train_clinical.txt', 'r').read()

train_data_list = []
target_data_list = []

for line in train_data:
  line = line.strip("\n")
  line = line.split("\t")
  train_data_list.append(line)

for line in targets:
  line = line.strip("\n")
  line = line.split("\t")
  target_data_list.append(line)

# Tranform the nested list to a numpy array.
train_data_array = np.array(train_data_list, dtype=object)
target_data_array = np.array(target_data_list, dtype=object)

# Print first column train data
#print(train_data_array[:,[0]])

# Print first row train data
#print(train_data_array[[0],:])
