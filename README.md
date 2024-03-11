# B4TM_group3

The repo for group 3 for the course Bioinformatics for Translational Medicine.
##Abstract
Motivation: In breast cancer, there are three receptor types: Estrogen Receptor, Progesterone Receptor,
and Human Epidermal growth factor Receptor 2 that are responsible for three main subtypes: HER2+,
Hormone Receptor positive, and Triple Negative. Machine learning (ML) models are used to predict breast
cancer subtype. This project aims to find the most accurate ML model to classify subtypes from patient
arrayCGH data. These models can be used to assess which genes qualify as biomarkers.

Method: The models that will be assessed are k-Nearest Neighbors (kNN), Support Vector Machines
(SVM) and Logistic Regression (LR). Models are trained by a double-loop cross-validation scheme. DNA
segments included in the final model could contain genes as potential biomarkers, and are selected by
ranking (kNN, SVM) or by regularization (LR).

Results: LR was the best performing model with an average accuracy of 0.82. All models included a
specific region on chromosomes 12 and 17. The latter contains multiple genes associated to breast cancer
(HER2, GRB7, MIEN1).

Conclusion: Logistic Regression with elastic net regularization is a promising classifier for breast cancer
subtype using arrayCGH data. The potential biomarkers HER2, GRB7 and MIEN1 were found in the final
model. These genes can be useful for development of adequate therapeutic methods.
