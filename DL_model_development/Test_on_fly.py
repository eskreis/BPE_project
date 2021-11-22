def Test_on_fly(Partition_pickle_name, Labels_int_binary_pickle_name, image_size1, scalar1, frozen1, extra1, surplus1, save_path1, batch_size1, folder_name):
    
    import cv2
    import math
    import matplotlib
    import matplotlib.pyplot as plt
    import numpy as np
    import os
    import pandas as pd
    import pickle
    import random
    import scipy.io as sio
    import tensorflow as tf
    import time
    from GetTestData import GenerateTestData
    from keras import applications, optimizers, regularizers
    from keras import backend as K  # you should pick if youre doing *K* or *k*
    from keras import backend as k
    from keras.callbacks import ModelCheckpoint, LearningRateScheduler, TensorBoard, EarlyStopping
    from keras.models import AveragePooling2D, BatchNormalization, Conv2D, Input, Dense, \
        Dropout, Sequential, Model, load_model, Reshape, MaxPooling2D, Flatten, \
        Dropout, Flatten, Dense, GlobalAveragePooling2D
    from keras.optimizers import Adam, SGD
    from keras.preprocessing.image import ImageDataGenerator
    from matplotlib import pyplot as plt
    from sklearn.metrics import auc, classification_report, confusion_matrix, roc_curve
    from tensorflow import keras
    from tensorflow.python.framework import ops
    from vgg16_model import vgg16_model


    
    classes = ['0', '1', '2', '3']
 
    num_classes = len(classes)
    
    f = open(Partition_pickle_name, 'rb')
    partition=pickle.load(f)
    f.close()
        
    f = open(Labels_int_binary_pickle_name, 'rb')
    labels=pickle.load(f)
    f.close()
        

    [X, X_labels, X_label_table, patient_id] = GenerateTestData(partition, labels, image_size1, classes,folder_name)
    
    
    model = load_model(save_path1)

    scores = model.evaluate(X, X_label_table)
    
    Y_recon = model.predict(X) 
    
    print("labels_test", labels)
    print("labels_test type", type(labels))
    
    print("Y_recon", Y_recon)
    print("Y_recon type", type(Y_recon))

    
    fpr_keras, tpr_keras, thresholds_keras = roc_curve(X_label_table[:,0], Y_recon[:,0])
    auc_keras = auc(fpr_keras, tpr_keras)

    Y = Y_recon


    return scores, fpr_keras, tpr_keras, thresholds_keras, auc_keras, X_label_table, Y, Y_recon,confusion_matrix, patient_id
