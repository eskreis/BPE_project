import numpy as np
import keras
import cv2
import random



class DataGenerator(keras.utils.Sequence):

    def __init__(self, list_IDs, labels, batch_size=32, dim=(224,224), n_channels=3, n_classes=2, shuffle=True, augmentation = 1):
        'Initialization'
        self.list_IDs = list_IDs
        self.labels = labels
        self.batch_size = batch_size
        self.dim = dim
        self.n_channels = n_channels
        self.n_classes = n_classes
        self.shuffle = shuffle
        self.on_epoch_end()
        self.augmentation = augmentation
    def on_epoch_end(self):
        'Updates indexes after each epoch'
        self.indexes = np.arange(len(self.list_IDs))
        if self.shuffle == True:
            np.random.shuffle(self.indexes)
            
    def __data_generation(self, list_IDs_temp):
        'Generates data containing batch_size samples' # X : (n_samples, *dim, n_channels)
        # Initialization
        X = np.empty((self.batch_size, *self.dim, self.n_channels))
        y = np.empty((self.batch_size), dtype=int)

        # Generate data
        for i, ID in enumerate(list_IDs_temp):
            image_size = 224
            image = cv2.imread(ID, cv2.IMREAD_GRAYSCALE)
            image = cv2.resize(image, (image_size, image_size), cv2.INTER_LINEAR)
            
            if self.augmentation == 1:
#                 print('AUGMENTATION ON********')
                ##flip with probability of 0.5
                if random.random() < 0.5:
                    image = np.flipud(image)
                if random.random() < 0.5:
                    image = np.fliplr(image)  
                ##flip to random orientation of 0, 90, 180, 270, +/- 10

                big_angle_options = [0,90,180,270]
                big_choose = random.randint(0,3)
                which_angle = big_angle_options[big_choose]

                # image_big_rotate = im_rotate(image, which_angle)  
                rows, cols = image.shape
                rotM_big = cv2.getRotationMatrix2D((cols/2-0.5, rows/2-0.5), which_angle, 1)
                imrotated_big = cv2.warpAffine(image, rotM_big, (cols, rows))


                little_choose = random.randint(-10,10)
                rows, cols = imrotated_big.shape
                rotM_little = cv2.getRotationMatrix2D((cols/2-0.5, rows/2-0.5), little_choose, 1)
                image = cv2.warpAffine(imrotated_big, rotM_little, (cols, rows))

#####
            if self.augmentation == 2:
#                 
                ##ONLY LR flip with probability of 0.5

                if random.random() < 0.5:
                    image = np.fliplr(image)  
                
                
            if self.augmentation == 3:
                ##LR flip with probability of 0.5 and small angle rotations

                if random.random() < 0.5:
                    image = np.fliplr(image)                  

                little_choose = random.randint(-10,10)
                rows, cols = image.shape
                rotM_little = cv2.getRotationMatrix2D((cols/2-0.5, rows/2-0.5), little_choose, 1)
                image = cv2.warpAffine(image, rotM_little, (cols, rows))

                
                #             else:
#                 print('AUGMENTATION OFF********')
                
            image = (image - np.mean(image)) / (np.amax(image) - np.amin(image) + .00000000000000001)  #normalize

            
            A = np.zeros([image_size, image_size,3])
            A[:,:,0]=image
            A[:,:,1]=image
            A[:,:,2]=image
            
            X[i,] = A
#             print('SIZE OF AAAAAA', A.shape)
          
            # X[i,] = np.load('data/' + ID + '.npy')

            # Store class
            y[i] = self.labels[ID]

        return X, keras.utils.to_categorical(y, num_classes=self.n_classes)
    
    

    def __len__(self):
        'Denotes the number of batches per epoch'
        print('batches_per_epoch', int(np.floor(len(self.list_IDs) / self.batch_size)))
        print('len_self.list_IDs', int(np.floor(len(self.list_IDs))))
        print('len_self.batchsize', (self.batch_size))

        return int(np.floor(len(self.list_IDs) / self.batch_size))
      
    
    
    def __getitem__(self, index):
        'Generate one batch of data'
        # Generate indexes of the batch
        indexes = self.indexes[index*self.batch_size:(index+1)*self.batch_size]

        # Find list of IDs
        list_IDs_temp = [self.list_IDs[k] for k in indexes]
#         print('listID before extraction', list_IDs_temp)
        
        # Generate data
        X, y = self.__data_generation(list_IDs_temp)
        
        return X, y