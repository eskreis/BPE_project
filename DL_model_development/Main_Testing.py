from Test_on_fly import Test_on_fly
from Train_on_fly import Train_on_fly
import numpy as np
import os
from scipy import io

reader =0

scalars        = [2] #left/right flips during data augmentation
learnings      = [1e-5]
epochs         = [10]
batches        = [32]
decays         = [1] #no correction for class imbalance

frozens = [0]  #indicates how many layers to freeze during training
extras = [126] #indicates location of training dataset
surpluses = [3] #surplus = 1 is for MIP model, surplus = 2 = slidingMIP model
models = [4] #indicates VGG19 model


Accuracy_train = np.empty((len(scalars),len(learnings),len(epochs),len(batches)))
Accuracy_validate = np.empty((len(scalars),len(learnings),len(epochs),len(batches),epochs[0]))
Loss_train = np.empty((len(scalars),len(learnings),len(epochs),len(batches),epochs[0]))
Loss_validate = np.empty((len(scalars),len(learnings),len(epochs),len(batches),epochs[0]))


for count_ss, ss in enumerate(scalars, start = 0):
    for count_ll, ll in enumerate(learnings, start = 0):
        for count_ee,ee in enumerate(epochs,start = 0):
            for count_bb,bb in enumerate(batches, start = 0):
                for count_dd, dd in enumerate(decays, start = 0):
                    for count_ff, ff in enumerate(frozens, start = 0):
                        for count_xx, xx in enumerate(extras, start = 0):
                            for count_uu, uu in enumerate(surpluses, start = 0):
                                for count_mm, mm in enumerate(models, start = 0):

            #                     try:
                                    image_size1         =  224
                                    scalar1             = ss
                                    learning_rate1      = ll
                                    num_epochs1         = ee
                                    minibatch_size1     = bb
                                    decay1              = dd
                                    frozen1             = ff
                                    extra1              = xx
                                    surplus1            = uu
                                    models1             = mm

                                    
                                    save_path1 = '/results/myresults_Lambda{}_LR{}_D{}_E{}_B{}_F{}_X{}_U{}_M{}.h5'.format(scalar1,learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1)



                                    if (surplus1 == 1):
                                        which = 'MIP'
                                    elif (surplus1 == 2):
                                        which = 'slidingMIP'
                                    else:
                                        which = 'error'

                                    if reader == 1:
                                        Partition_pickle_name = "/Reader/Partition_{}.pkl".format(which)
                                        Labels_int_binary_pickle_name = "Reader/Labels_int0123_{}.pkl".format(which) 
                                        folder00 = 'test_results_readerstudy'
                                        folder_name = 'Reader'

                                    else: 
                                        Partition_pickle_name = "/BIRADS45/Partition_{}.pkl".format(which)
                                        Labels_int_binary_pickle_name = "/BIRADS45/Labels_int0123_{}.pkl".format(which)         
                                        folder00 = 'test_results'
                                        folder_name = 'B45'
    

                                    scores, fpr_keras, tpr_keras, thresholds_keras, auc_keras, labels_test, Y, Y_recon, confusion_matrix, patient_id = Test_on_fly(Partition_pickle_name, Labels_int_binary_pickle_name, image_size1, scalar1, frozen1, extra1, surplus1, save_path1, minibatch_size1, folder_name)
    
                                    Auc_Keras = '/{}/auc_keras_Lambda{}_LR{}_D{}_E{}_B{}_F{}_X{}_U{}_M{}.npy'.format(folder00, scalar1,learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1)
                                    Labels_Test = '/{}/labels_test_Lambda{}_LR{}_D{}_E{}_B{}_F{}_X{}_U{}_M{}.npy'.format(folder00, scalar1,learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1)
                                    YY = '/{}/Y_Lambda{}_LR{}_D{}_E{}_B{}_F{}_X{}_U{}_M{}.npy'.format(folder00, scalar1,learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1)
                                    YY_recon = '/{}/Y_recon_Lambda{}_LR{}_D{}_E{}_B{}_F{}_X{}_U{}_M{}.npy'.format(folder00, scalar1,learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1)
                                    Confusion_Matrix = '/{}/confusion_matrix_Lambda{}_LR{}_D{}_E{}_B{}_F{}_X{}_U{}_M{}.npy'.format(folder00, scalar1,learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1)
                                    patient_idid = '/{}/patient_id_Lambda{}_LR{}_D{}_E{}_B{}_F{}_X{}_U{}_M{}.npy'.format(folder00,scalar1,learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1)
                        
                                    np.save(Auc_Keras,auc_keras)
                                    np.save(Labels_Test,labels_test)

                                    np.save(YY,Y)
                                    np.save(YY_recon,Y_recon)
                                    np.save(Confusion_Matrix,confusion_matrix)
                                    np.save(patient_idid,patient_id)

