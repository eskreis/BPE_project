def Train_on_fly(Partition_pickle_name, Labels_int_binary_pickle_name, image_size1, scalar1, learning_rate1, decay1, num_epochs1, batch_size1, frozen1, extra1, surplus1, save_path1, models1):

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
    from Data_gen import DataGenerator


    classes = ['0', '1', '2', '3']

    # Parameters
    params = {
            'batch_size': batch_size1,
            'dim': (224, 224),
            'n_channels': 3,
            'n_classes': 4,
            'shuffle': True,
            'augmentation': scalar1}

    
    f = open(Partition_pickle_name, 'rb')
    partition=pickle.load(f)
    f.close()
        
    f = open(Labels_int_binary_pickle_name, 'rb')
    labels=pickle.load(f)
    f.close()

    # Generators
    training_generator = DataGenerator(partition['Train'], labels, **params)
    validation_generator = DataGenerator(partition['Valid'], labels, **params)
 
    if models1 ==4:
        model = applications.VGG19(weights = "imagenet", include_top=False, input_shape = (image_size1, image_size1, 3))
   
    for layer in model.layers[:frozen1]:
        layer.trainable = False

    #Adding custom Layers 
    x = model.output
    x = Flatten()(x)
    
    if models1 == 4:
        x = Dense(1024, activation="relu")(x)
        x = Dropout(0.75)(x)
        x = Dense(1024, activation="relu")(x)
     
    predictions = Dense(4, activation="softmax")(x)    
    
    # creating the final model 
    model_final = Model(input = model.input, output = predictions)


    model_final.compile(loss = "categorical_crossentropy", optimizer = optimizers.SGD(lr=learning_rate1, momentum=0.9), metrics=["accuracy"])


    history_callback = model_final.fit_generator(generator=training_generator,
                    validation_data=validation_generator,
                    use_multiprocessing=True,
                    workers=4, epochs = num_epochs1, verbose = 1, class_weight = [1,decay1])        
        
    
    print(history_callback.history.keys())

    my_acc_train = history_callback.history['acc']
    my_loss_train = history_callback.history['loss']

    my_acc_valid = history_callback.history['val_acc']
    my_loss_valid = history_callback.history['val_loss']

    model_final.save(save_path1)  # creates a HDF5 file 'my_model.h5'


    return my_acc_train, my_loss_train, my_acc_valid, my_loss_valid

