% case_number = is case ID for each breast MRI exam to be pre-processing


for zz = 1:length(case_number)
    sub_SD=[];
    post_sub_SD = [];
    post_series_numSD =[];
    pre_series_numSD=[];
    ACC_DID=[];
    ACC_DID_all=[];
    pre_series_num = [];
    
    %%this pulls out the BPE label, medical record number, accession number and BIRADS score from our database
    label = BPE4_matrix(zz) 
    MRN = B4_matrix(zz,1);
    ACC = B4_matrix(zz,2);
    BIRADS = B4_matrix(zz,3);
       
    
    
    %%
    %this checks the accession number against our MasterDataStruct databases to determine if
    %it is benign/malignant and if we have negative imaging followup for 2
    %years
    
    if length(find(ACC45_malig==ACC))
        MasterDataStruct_ALL(zz).pathology_list='ACC45_malig'
        MasterDataStruct_ALL(zz).binary_pathology_list='MALIG_HR'
        folder_pathology_MIP =        '/data_ALL/PATH/MIP/MALIG_HR'
        folder_pathology_slidingMIP = '/data_ALL/PATH/slidingMIP/MALIG_HR'
    elseif length(find(ACC45_benign==ACC))
        MasterDataStruct_ALL(zz).pathology_list='ACC45_benign'
        MasterDataStruct_ALL(zz).binary_pathology_list='BENIGN'
        folder_pathology_MIP =        '/data_ALL/PATH/MIP/BENIGN'
        folder_pathology_slidingMIP = '/data_ALL/PATH/slidingMIP/BENIGN'
    elseif length(find(ACC6_preNAC==ACC))
        MasterDataStruct_ALL(zz).pathology_list='ACC6_preNAC'
        MasterDataStruct_ALL(zz).binary_pathology_list='MALIG_HR'
        folder_pathology_MIP =        '/data_ALL/PATH/MIP/MALIG_HR'
        folder_pathology_slidingMIP = '/data_ALL/PATH/slidingMIP/MALIG_HR'
    elseif length(find(ACC_negative2yrs==ACC))
        MasterDataStruct_ALL(zz).pathology_list='ACC_negative2yrs'
        MasterDataStruct_ALL(zz).binary_pathology_list='BENIGN'
        folder_pathology_MIP =        '/data_ALL/PATH/MIP/BENIGN'
        folder_pathology_slidingMIP = '/data_ALL/PATH/slidingMIP/BENIGN'
    else
        MasterDataStruct_ALL(zz).pathology_list='NotFound'
        folder_pathology_MIP = '/data_ALL/PATH/MIP/NotFound'
        folder_pathology_slidingMIP = '/data_ALL/PATH/slidingMIP/NotFound'
        
    end
    
    
    %%
    
    
   
    
    try
        %this searches for the exam within our database, trying several
        %folder path options to find the right spot (folder0, folder02,
        %folder0_double, etc)
        [series, SDcount, SDcount_sag, folder000] = create_series(bbb,folder0, folder02, folder0_double, folder02_double,ACC);
        
        %this checks if the exam is predominently sagittal acquisition
        if SDcount > 2 & SDcount_sag < 6
            
            [series_thinslice, series_thinsliceS] = create_thinslice_thinsliceS(series)
            MasterDataStruct_ALL(zz).series_thinslice = series_thinslice;
            MasterDataStruct_ALL(zz).series_thinsliceS = series_thinsliceS;
            

            %search if there is a subtraction image in the exam
            extra = 0;
            Sub_yes = 0;
            try
                [SUB, sub_field_name, sub_SD, endnow] = generate_sub1(bbb,folder000,series, ACC);
                if endnow == 1
                    msg
                end
                
                Sub_yes = 1;
                %we will identify the post1 series based on the
                %seriesdescription of the sub
                
                [CodePost1oo, post_SD] = generate_code_post(bbb,folder000,series,sub_field_name,ACC);
            catch
                %                 since no sub, look for first series with GAD, and then pull
                %                 the series right before that one too...
                extra = 100;
            end
            
            try
                
                if extra == 100                   
                    [Pre1oo_ends, p3s, SUB, post_series_numSD, pre_series_numSD] = generate_pre_post(bbb,folder000,series,series_thinsliceS, ACC);
                end
                
                MIP_total=[];
                MIP_total = max(SUB,[],3);             
                MIPglobalmax = max(MIP_total(:));
                
                
                sizeSUB=size(SUB);
                sub3=sizeSUB(3);
                sub_range = ceil(sub3*.05):floor(sub3*.95)
                len_range = length(sub_range)
                range1 = sub_range(1:ceil(len_range/3))
                range2 = sub_range(ceil(len_range/3):ceil((2*len_range)/3))
                range3 = sub_range(ceil((2*len_range)/3):end)
 
                
                if length(SUB)>256
                    USE_POST=[];
                    if Sub_yes
                        USE_POST = CodePost1oo;
                    else
                        USE_POST  = p3s;
                    end
                    
                    Post_left_edge=[];
                    Post_right_edge=[];
                    Post_RL_edge =[];
                    L_dim1 =[];
                    L_dim2 =[];
                    R_dim1 =[];
                    R_dim2 =[];
                    RL_dim1 =[];
                    RL_dim2 =[];
                    breast_containing_slices=[];
                    
                    %this will crop the image so that the breasts are
                    %included, but much of the background is excluded
                    [Post_left_edge, Post_right_edge,Post_RL_edge, L_dim1, L_dim2, R_dim1, R_dim2, RL_dim1, RL_dim2, breast_containing_slices] = Crop_image_2breasts2021(USE_POST);
                    
                    
                    %%below several MIPs are calculated
                    Sub_left = SUB(L_dim1,L_dim2,:);
                    Sub_right = SUB(R_dim1,R_dim2,:);
                    Sub_RL = SUB(RL_dim1,RL_dim2,:);
             
                    MIP_left = max(Sub_left,[],3);
                    MIP_right = max(Sub_right,[],3);
                    MIP_RL = max(Sub_RL,[],3);
                    MIP_RL_ff = max(SUB,[],3);
                    
                    
                    MIP1_leftN = MIP_left/MIPglobalmax;
                    MIP1_rightN = MIP_right/MIPglobalmax;
                    MIP1_RLN = MIP_RL/MIPglobalmax;
                    MIP1_RLN_ff = MIP_RL_ff/MIPglobalmax;
                    
%%
                    MIP_left_1of3 = max(SUB(L_dim1,L_dim2,range1),[],3);
                    MIP_left_2of3 = max(SUB(L_dim1,L_dim2,range2),[],3);
                    MIP_left_3of3 = max(SUB(L_dim1,L_dim2,range3),[],3);
                    
                    MIP_right_1of3 = max(SUB(R_dim1,R_dim2,range1),[],3);
                    MIP_right_2of3 = max(SUB(R_dim1,R_dim2,range2),[],3);
                    MIP_right_3of3 = max(SUB(R_dim1,R_dim2,range3),[],3);
                    
                    
                    MIP_RL_1of3 = max(SUB(RL_dim1,RL_dim2,range1),[],3);
                    MIP_RL_2of3 = max(SUB(RL_dim1,RL_dim2,range2),[],3);
                    MIP_RL_3of3 = max(SUB(RL_dim1,RL_dim2,range3),[],3);
                    %%
                    
                    MIP_left_1of3N=MIP_left_1of3/MIPglobalmax;
                    MIP_left_2of3N=MIP_left_2of3/MIPglobalmax;
                    MIP_left_3of3N=MIP_left_3of3/MIPglobalmax;
                    
                    MIP_right_1of3N=MIP_right_1of3/MIPglobalmax;
                    MIP_right_2of3N=MIP_right_2of3/MIPglobalmax;
                    MIP_right_3of3N=MIP_right_3of3/MIPglobalmax;
                    
                    MIP_RL_1of3N = MIP_RL_1of3/MIPglobalmax;
                    MIP_RL_2of3N = MIP_RL_2of3/MIPglobalmax;
                    MIP_RL_3of3N = MIP_RL_3of3/MIPglobalmax;
                   
                    
                    
                    %%also create slab MIPs
                    L_center = Sub_left(:,:,breast_containing_slices);
                    R_center = Sub_right(:,:,breast_containing_slices);
                    
                    L_centerN = L_center/max(L_center(:));
                    R_centerN = R_center/max(R_center(:));
                    %%
                    folder_path_BPE=[];
                    folder_path_BPEsub=[];
                    folder_path_BPE_slidingMIP=[];
                    
                    if length(find(BPE00))>1
                        folder_path_BPE = '/data_ALL/BPE/999'
                        folder_path_BPEsub = '/data_ALL/BPE/slices/999'
                        folder_path_BPE_slidingMIP = '/data_ALL/BPE/slidingMIP/999'
                    else
                        
                        if BPE00(4) == 1
                            folder_path_BPE = '/data_ALL/BPE/MIP/Marked'
                            folder_path_BPEsub = '/data_ALL/BPE/slices/Marked'
                            folder_path_BPE_slidingMIP = '/data_ALL/BPE/slidingMIP/Marked'
                        elseif BPE00(3) == 1
                            folder_path_BPE = '/data_ALL/BPE/MIP/Moderate'
                            folder_path_BPEsub = '/data_ALL/BPE/slices/Moderate'
                            folder_path_BPE_slidingMIP = '/data_ALL/BPE/slidingMIP/Moderate'

                        elseif BPE00(2) == 1
                            folder_path_BPE = '/data_ALL/BPE/MIP/Mild'
                            folder_path_BPEsub = '/data_ALL/BPE/slices/Mild'
                            folder_path_BPE_slidingMIP = '/data_ALL/BPE/slidingMIP/Mild'

                        elseif BPE00(1) == 1
                            folder_path_BPE = '/data_ALL/BPE/MIP/Minimal'
                            folder_path_BPEsub = '/data_ALL/BPE/slices/Minimal'
                            folder_path_BPE_slidingMIP = '/data_ALL/BPE/slidingMIP/Minimal'

                        else
                            folder_path_BPE = '/data_ALL/BPE/999'
                            folder_path_BPEsub = '/data_ALL/BPE/slices/999'
                            folder_path_BPE_slidingMIP = '/data_ALL/BPE/slidingMIP/999'

                            
                        end
                    end

                    
                    folder_path_BIRADS_MIP = [];
                    folder_path_BIRADS_slidingMIP=[];
                    
                    
                    if BIRADS == 1
                        folder_path_BIRADS_MIP = '/data_ALL/BIRADS/MIP/1'
                        folder_path_BIRADS_slidingMIP = '/data_ALL/BIRADS/slidingMIP/1'
                    elseif BIRADS == 2
                        folder_path_BIRADS_MIP = '/data_ALL/BIRADS/MIP/2'
                        folder_path_BIRADS_slidingMIP = '/data_ALL/BIRADS/slidingMIP/2'
                    elseif BIRADS == 3
                        folder_path_BIRADS_MIP = '/data_ALL/BIRADS/MIP/3'
                        folder_path_BIRADS_slidingMIP = '/data_ALL/BIRADS/slidingMIP/3'
                    elseif BIRADS == 4
                        folder_path_BIRADS_MIP = '/data_ALL/BIRADS/MIP/4'
                        folder_path_BIRADS_slidingMIP = '/data_ALL/BIRADS/slidingMIP/4'
                    elseif BIRADS == 5
                        folder_path_BIRADS_MIP = '/data_ALL/BIRADS/MIP/5'
                        folder_path_BIRADS_slidingMIP = '/data_ALL/BIRADS/slidingMIP/5'
                    elseif BIRADS == 6
                        folder_path_BIRADS_MIP = '/data_ALL/BIRADS/MIP/6'
                        folder_path_BIRADS_slidingMIP = '/data_ALL/BIRADS/slidingMIP/6'
                    else
                        folder_path_BIRADS_MIP = '/data_ALL/BIRADS/MIP/999'
                        folder_path_BIRADS_slidingMIP = '/data_ALL/BIRADS/slidingMIP/999'
                    end
                    

                  
                    initial_folder = '/data_ALL/MATLAB_storage'
                    initial_folder_acc = strcat(initial_folder,'/',num2str(ACC))
  
                    
                    where_to_save_mat0 = [];
                    where_to_save_mat0pre = [];
                    where_to_save_mat0post = [];
                    
                    mkdir (initial_folder)
                    mkdir (initial_folder_acc)
                    where_to_save_mat0 = sprintf('%s/sub1_%s.mat',initial_folder_acc,num2str(ACC))
                    where_to_save_mat0post = sprintf('%s/post_%s.mat',initial_folder_acc,num2str(ACC))
                    save(where_to_save_mat0, 'SUB');
                    save(where_to_save_mat0post, 'USE_POST');
                    
                    
                    
                    folder_path_BIRADS_MIP_MRN=[];
                    folder_path_BIRADS_slidingMIP_MRN =[];
                    folder_pathology_BIRADS_MIP = [];
                    folder_pathology_BIRADS_slidingMIP = [];
                    
                    folder_path_BIRADS_MIP_MRN = sprintf('%s/%i/%i', folder_path_BIRADS_MIP, MRN, ACC)
                    folder_path_BIRADS_slidingMIP_MRN = sprintf('%s/%i/%i', folder_path_BIRADS_slidingMIP, MRN, ACC)
                    mkdir (folder_path_BIRADS_MIP_MRN)
                    mkdir (folder_path_BIRADS_slidingMIP_MRN)
                    
                    
                    folder_pathology_BIRADS_MIP_MRN = sprintf('%s/%i/%i', folder_pathology_MIP, MRN, ACC)
                    folder_pathology_BIRADS_slidingMIP_MRN = sprintf('%s/%i/%i', folder_pathology_slidingMIP, MRN, ACC)
                    mkdir (folder_pathology_BIRADS_MIP_MRN)
                    mkdir (folder_pathology_BIRADS_slidingMIP_MRN)
                    
                    
                    where_to_save_BIRADS_MIP_MIP1_L=[];
                    where_to_save_BIRADS_MIP_MIP1_R=[];
                    where_to_save_BIRADS_MIP_1of3_R =[];
                    where_to_save_BIRADS_MIP_2of3_R =[];
                    where_to_save_BIRADS_MIP_3of3_R =[];
                    where_to_save_BIRADS_MIP_1of3_L =[];
                    where_to_save_BIRADS_MIP_2of3_L =[];
                    where_to_save_BIRADS_MIP_3of3_L =[];
                    where_to_save_BIRADS_MIP_1of3_RL=[];
                    where_to_save_BIRADS_MIP_2of3_RL =[];
                    where_to_save_BIRADS_MIP_3of3_RL =[];   
                    
                    
                    where_to_save_BIRADS_MIP_L = strcat(folder_path_BIRADS_MIP_MRN, '/', 'MIP_L.jpg')
                    where_to_save_BIRADS_MIP_R = strcat(folder_path_BIRADS_MIP_MRN, '/', 'MIP_R.jpg')
                    where_to_save_BIRADS_MIP_RL = strcat(folder_path_BIRADS_MIP_MRN, '/', 'MIP_RL.jpg')
                    where_to_save_BIRADS_MIP_RL_ff = strcat(folder_path_BIRADS_MIP_MRN, '/', 'MIP_RL_ff.jpg')
                    
                    where_to_save_BIRADS_MIP_1of3_R = strcat(folder_path_BIRADS_slidingMIP_MRN, '/', 'MIP_1of3_R.jpg')
                    where_to_save_BIRADS_MIP_2of3_R = strcat(folder_path_BIRADS_slidingMIP_MRN, '/', 'MIP_2of3_R.jpg')
                    where_to_save_BIRADS_MIP_3of3_R = strcat(folder_path_BIRADS_slidingMIP_MRN, '/', 'MIP_3of3_R.jpg')
                    where_to_save_BIRADS_MIP_1of3_L = strcat(folder_path_BIRADS_slidingMIP_MRN, '/', 'MIP_1of3_L.jpg')
                    where_to_save_BIRADS_MIP_2of3_L = strcat(folder_path_BIRADS_slidingMIP_MRN, '/', 'MIP_2of3_L.jpg')
                    where_to_save_BIRADS_MIP_3of3_L = strcat(folder_path_BIRADS_slidingMIP_MRN, '/', 'MIP_3of3_L.jpg')
                    where_to_save_BIRADS_MIP_1of3_RL = strcat(folder_path_BIRADS_slidingMIP_MRN, '/', 'MIP_1of3_RL.jpg')
                    where_to_save_BIRADS_MIP_2of3_RL = strcat(folder_path_BIRADS_slidingMIP_MRN, '/', 'MIP_2of3_RL.jpg')
                    where_to_save_BIRADS_MIP_3of3_RL = strcat(folder_path_BIRADS_slidingMIP_MRN, '/', 'MIP_3of3_RL.jpg')            
                    
                    %%
                    where_to_save_pathology_BIRADS_MIP_MIP1_L=[];
                    where_to_save_pathology_BIRADS_MIP_MIP1_R=[];
                    where_to_save_pathology_BIRADS_MIP_1of3_R =[];
                    where_to_save_pathology_BIRADS_MIP_2of3_R =[];
                    where_to_save_pathology_BIRADS_MIP_3of3_R =[];
                    where_to_save_pathology_BIRADS_MIP_1of3_L =[];
                    where_to_save_pathology_BIRADS_MIP_2of3_L =[];
                    where_to_save_pathology_BIRADS_MIP_3of3_L =[];
                    where_to_save_pathology_BIRADS_MIP_1of3_RL=[];
                    where_to_save_pathology_BIRADS_MIP_2of3_RL =[];
                    where_to_save_pathology_BIRADS_MIP_3of3_RL =[];   
                    
                    
                    where_to_save_pathology_BIRADS_MIP_L = strcat(folder_pathology_BIRADS_MIP_MRN, '/', 'MIP_L.jpg')
                    where_to_save_pathology_BIRADS_MIP_R = strcat(folder_pathology_BIRADS_MIP_MRN, '/', 'MIP_R.jpg')
                    where_to_save_pathology_BIRADS_MIP_RL = strcat(folder_pathology_BIRADS_MIP_MRN, '/', 'MIP_RL.jpg')
                    where_to_save_pathology_BIRADS_MIP_RL_ff = strcat(folder_pathology_BIRADS_MIP_MRN, '/', 'MIP_RL_ff.jpg')
                    
                    where_to_save_pathology_BIRADS_MIP_1of3_R = strcat(folder_pathology_BIRADS_slidingMIP_MRN, '/', 'MIP_1of3_R.jpg')
                    where_to_save_pathology_BIRADS_MIP_2of3_R = strcat(folder_pathology_BIRADS_slidingMIP_MRN, '/', 'MIP_2of3_R.jpg')
                    where_to_save_pathology_BIRADS_MIP_3of3_R = strcat(folder_pathology_BIRADS_slidingMIP_MRN, '/', 'MIP_3of3_R.jpg')
                    where_to_save_pathology_BIRADS_MIP_1of3_L = strcat(folder_pathology_BIRADS_slidingMIP_MRN, '/', 'MIP_1of3_L.jpg')
                    where_to_save_pathology_BIRADS_MIP_2of3_L = strcat(folder_pathology_BIRADS_slidingMIP_MRN, '/', 'MIP_2of3_L.jpg')
                    where_to_save_pathology_BIRADS_MIP_3of3_L = strcat(folder_pathology_BIRADS_slidingMIP_MRN, '/', 'MIP_3of3_L.jpg')
                    where_to_save_pathology_BIRADS_MIP_1of3_RL = strcat(folder_pathology_BIRADS_slidingMIP_MRN, '/', 'MIP_1of3_RL.jpg')
                    where_to_save_pathology_BIRADS_MIP_2of3_RL = strcat(folder_pathology_BIRADS_slidingMIP_MRN, '/', 'MIP_2of3_RL.jpg')
                    where_to_save_pathology_BIRADS_MIP_3of3_RL = strcat(folder_pathology_BIRADS_slidingMIP_MRN, '/', 'MIP_3of3_RL.jpg')      
                    
                    
                    
                    
                    folder_path_BPE_MRN = sprintf('%s/%i/%i', folder_path_BPE, MRN,ACC)
                    folder_path_BPEsub_MRN = sprintf('%s/%i/%i', folder_path_BPEsub, MRN, ACC)
                    folder_path_BPE_slidingMIP_MRN = sprintf('%s/%i/%i', folder_path_BPE_slidingMIP, MRN, ACC)
                    mkdir (folder_path_BPE_MRN)
                    mkdir (folder_path_BPEsub_MRN)
                    mkdir (folder_path_BPE_slidingMIP_MRN)
                    where_to_save_BPE_MIP1_L = strcat(folder_path_BPE_MRN, '/', 'MIP_L.jpg')
                    where_to_save_BPE_MIP1_R = strcat(folder_path_BPE_MRN, '/', 'MIP_R.jpg')
                    
                    where_to_save_BPE_MIP_1of3_R = strcat(folder_path_BPE_slidingMIP_MRN, '/', 'MIP_1of3_R.jpg')
                    where_to_save_BPE_MIP_2of3_R = strcat(folder_path_BPE_slidingMIP_MRN, '/', 'MIP_2of3_R.jpg')
                    where_to_save_BPE_MIP_3of3_R = strcat(folder_path_BPE_slidingMIP_MRN, '/', 'MIP_3of3_R.jpg')
                    
                    where_to_save_BPE_MIP_1of3_L = strcat(folder_path_BPE_slidingMIP_MRN, '/', 'MIP_1of3_L.jpg')
                    where_to_save_BPE_MIP_2of3_L = strcat(folder_path_BPE_slidingMIP_MRN, '/', 'MIP_2of3_L.jpg')
                    where_to_save_BPE_MIP_3of3_L = strcat(folder_path_BPE_slidingMIP_MRN, '/', 'MIP_3of3_L.jpg')
                    
                    where_to_save_BPE_MIP_1of3_RL = strcat(folder_path_BPE_slidingMIP_MRN, '/', 'MIP_1of3_RL.jpg')
                    where_to_save_BPE_MIP_2of3_RL = strcat(folder_path_BPE_slidingMIP_MRN, '/', 'MIP_2of3_RL.jpg')
                    where_to_save_BPE_MIP_3of3_RL = strcat(folder_path_BPE_slidingMIP_MRN, '/', 'MIP_3of3_RL.jpg')
                    
                    for ii = 1:length(breast_containing_slices)
                        count_nameMIP1_L = sprintf('MIP1_L_slab_%i_of_%i.jpg', ii, length(breast_containing_slices));
                        where_to_save_new_slab_MIP1_L = strcat(folder_path_BPEsub_MRN, '/',count_nameMIP1_L);
                        imwrite(L_centerN(:,:,ii),where_to_save_new_slab_MIP1_L);
                        
                        count_nameMIP1_R = sprintf('MIP1_R_slab_%i_of_%i.jpg', ii, length(breast_containing_slices));
                        where_to_save_new_slab_MIP1_R = strcat(folder_path_BPEsub_MRN, '/',count_nameMIP1_R);
                        imwrite(R_centerN(:,:,ii),where_to_save_new_slab_MIP1_R);
                        
                        
                    end
                    
                    imwrite(MIP1_leftN,where_to_save_pathology_BIRADS_MIP_L);
                    imwrite(MIP1_rightN,where_to_save_pathology_BIRADS_MIP_R);
                    imwrite(MIP1_RLN,where_to_save_pathology_BIRADS_MIP_RL);
                    imwrite(MIP1_RLN_ff,where_to_save_pathology_BIRADS_MIP_RL_ff);
                    
                    imwrite(MIP_right_1of3N,where_to_save_pathology_BIRADS_MIP_1of3_R)
                    imwrite(MIP_right_2of3N,where_to_save_pathology_BIRADS_MIP_2of3_R)
                    imwrite(MIP_right_3of3N,where_to_save_pathology_BIRADS_MIP_3of3_R)
                    imwrite(MIP_left_1of3N,where_to_save_pathology_BIRADS_MIP_1of3_L)
                    imwrite(MIP_left_2of3N,where_to_save_pathology_BIRADS_MIP_2of3_L)
                    imwrite(MIP_left_3of3N,where_to_save_pathology_BIRADS_MIP_3of3_L)
                    imwrite(MIP_RL_1of3N,where_to_save_pathology_BIRADS_MIP_1of3_RL)
                    imwrite(MIP_RL_2of3N,where_to_save_pathology_BIRADS_MIP_2of3_RL)
                    imwrite(MIP_RL_3of3N,where_to_save_pathology_BIRADS_MIP_3of3_RL)
                                        
                    
                    imwrite(MIP1_leftN,where_to_save_BIRADS_MIP_L);
                    imwrite(MIP1_rightN,where_to_save_BIRADS_MIP_R);
                    imwrite(MIP1_RLN,where_to_save_BIRADS_MIP_RL);
                    imwrite(MIP1_RLN_ff,where_to_save_BIRADS_MIP_RL_ff);
 
                    imwrite(MIP_right_1of3N,where_to_save_BIRADS_MIP_1of3_R)
                    imwrite(MIP_right_2of3N,where_to_save_BIRADS_MIP_2of3_R)
                    imwrite(MIP_right_3of3N,where_to_save_BIRADS_MIP_3of3_R)
                    imwrite(MIP_left_1of3N,where_to_save_BIRADS_MIP_1of3_L)
                    imwrite(MIP_left_2of3N,where_to_save_BIRADS_MIP_2of3_L)
                    imwrite(MIP_left_3of3N,where_to_save_BIRADS_MIP_3of3_L)
                    imwrite(MIP_RL_1of3N,where_to_save_BIRADS_MIP_1of3_RL)
                    imwrite(MIP_RL_2of3N,where_to_save_BIRADS_MIP_2of3_RL)
                    imwrite(MIP_RL_3of3N,where_to_save_BIRADS_MIP_3of3_RL)
                    
                    
                    imwrite( MIP1_leftN ,where_to_save_BPE_MIP1_L);
                    imwrite( MIP1_rightN ,where_to_save_BPE_MIP1_R);

                    imwrite( MIP_right_1of3N ,where_to_save_BPE_MIP_1of3_R);
                    imwrite( MIP_right_2of3N ,where_to_save_BPE_MIP_2of3_R);
                    imwrite( MIP_right_3of3N ,where_to_save_BPE_MIP_3of3_R);

                    
                    imwrite( MIP_left_1of3N ,where_to_save_BPE_MIP_1of3_L);
                    imwrite( MIP_left_2of3N ,where_to_save_BPE_MIP_2of3_L);
                    imwrite( MIP_left_3of3N ,where_to_save_BPE_MIP_3of3_L);

                    imwrite( MIP_RL_1of3N ,where_to_save_BPE_MIP_1of3_RL);
                    imwrite( MIP_RL_2of3N ,where_to_save_BPE_MIP_2of3_RL);
                    imwrite( MIP_RL_3of3N ,where_to_save_BPE_MIP_3of3_RL);
                    
                else                   
                end
            catch                
            end 
        end        
    catch        
    end   
end




