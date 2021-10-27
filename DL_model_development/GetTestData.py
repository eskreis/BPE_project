import numpy as np
import cv2
import random
import pickle

def GenerateTestData(partition, labels, image_size, classes, folder_name):

    XX=[];
    XX_labels=[];
    label_table=[];
    patient_id = [];
    
    num_cases=len(partition[folder_name])
    
    for ii in range(num_cases):
        image_pt=partition[folder_name][ii]
        label_pt = labels[image_pt]

        image = cv2.imread(image_pt, cv2.IMREAD_GRAYSCALE)
        image = cv2.resize(image, (image_size, image_size), cv2.INTER_LINEAR)
        image = (image - np.mean(image)) / (np.amax(image) - np.amin(image) + .00000000000000001)  #normalize

        A = np.zeros([image_size, image_size,3])
        A[:,:,0]=image
        A[:,:,1]=image
        A[:,:,2]=image

        XX.append(A)

        label = np.zeros(len(classes))
        label[label_pt] = 1.0
        XX_labels.append(label_pt)
        label_table.append(label)
        patient_id.append(image_pt)
        
    X = np.array(XX)
    X_labels = np.array(XX_labels)
    X_label_table = np.array(label_table)
    patient_id1 = np.array(patient_id)

    
    


    
    return X, X_labels, X_label_table, patient_id
