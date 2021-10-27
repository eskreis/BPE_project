def Test_on_fly(Partition_pickle_name, Labels_int_binary_pickle_name, image_size1, scalar1, frozen1, extra1, surplus1, save_path1, batch_size1, folder_name):
    
    import tensorflow as tf
    from tensorflow import keras
    import pickle
    import numpy as np

    from keras.models import Sequential, Model
    from keras.layers import Dense
    from keras.layers import Conv2D, Input
    from keras.layers import Conv2DTranspose
    from keras.layers import Dropout
    from keras.layers import MaxPooling2D
    from keras.layers import Flatten
    from keras.layers import Dense
    from keras.layers import Reshape
    from keras.layers import AveragePooling2D, BatchNormalization
    from keras import optimizers
    from keras import regularizers
    from keras.optimizers import Adam
    from keras import applications
    from keras.preprocessing.image import ImageDataGenerator
    from keras import optimizers
    from keras.models import Sequential, Model 
    from keras.layers import Dropout, Flatten, Dense, GlobalAveragePooling2D
    from keras import backend as k 
    from keras.callbacks import ModelCheckpoint, LearningRateScheduler, TensorBoard, EarlyStopping
    from keras.preprocessing.image import ImageDataGenerator

    from tensorflow.python.framework import ops
    import math
    import time
    import random
    import pandas as pd
    import os
    import matplotlib
    from matplotlib import pyplot as plt
    import cv2
    from keras.optimizers import Adam
    from keras import backend as K
    from vgg16_model import vgg16_model 
    from keras.optimizers import SGD
    import scipy.io as sio
    from keras.models import load_model
    import time
    import math
    import random
    import pandas as pd
    import matplotlib.pyplot as plt
    import cv2
    import os
    from sklearn.metrics import roc_curve
    from sklearn.metrics import auc
    from sklearn.metrics import classification_report, confusion_matrix    
    from GetTestData import GenerateTestData
    
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