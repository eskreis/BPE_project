from Test_on_fly import Test_on_fly
from Train_on_fly import Train_on_fly
import numpy as np
import os


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

                                    print('HYPERPARAMETERS LISTED HERE: SC: {}, LR: {}, D: {}, E: {}, B: {} F: {}, Extras: {}, Sur: {}, Mod: {}'.format(scalar1, learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1))

                                    save_path1 = '/myresults_Lambda{}_LR{}_D{}_E{}_B{}_F{}_X{}_U{}_M{}.h5'.format(scalar1,learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1)

                                    if (surplus1 == 1):
                                        which = 'MIP'
                                    elif (surplus1 == 2):
                                        which = 'slidingMIP'
                                    else:
                                        which = 'error'


                                    if extra1 == 126:
                                        Partition_pickle_name = "Partition_{}.pkl".format(which)
                                        Labels_int_binary_pickle_name = "Labels_int0123_{}.pkl".format(which)                   
                                        

                                    my_acc_train, my_loss_train, my_acc_valid, my_loss_valid = Train_on_fly(Partition_pickle_name, Labels_int_binary_pickle_name, image_size1, scalar1, learning_rate1, decay1, num_epochs1, minibatch_size1, frozen1, extra1, surplus1, save_path1, models1)


                                    AccTrain_callbacks = 'log/AccTrain_Lambda{}_LR{}_D{}_E{}_B{}_F{}_X{}_U{}_M{}.npy'.format(scalar1,learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1)
                                    AccValid_callbacks = 'log/AccValid_Lambda{}_LR{}_D{}_E{}_B{}_F{}_X{}_U{}_M{}.npy'.format(scalar1,learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1)
                                    LossTrain_callbacks = 'log/LossTrain_Lambda{}_LR{}_D{}_E{}_B{}_F{}_X{}_U{}_M{}.npy'.format(scalar1,learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1)
                                    LossValid_callbacks = 'log/LossValid_Lambda{}_LR{}_D{}_E{}_B{}_F{}_X{}_U{}_M{}.npy'.format(scalar1,learning_rate1,decay1,num_epochs1,minibatch_size1, frozen1, extra1, surplus1, models1)

                                    np.save(AccTrain_callbacks,my_acc_train)
                                    np.save(AccValid_callbacks,my_acc_valid)
                                    np.save(LossTrain_callbacks,my_loss_train)
                                    np.save(LossValid_callbacks,my_loss_valid)

