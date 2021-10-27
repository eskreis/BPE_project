load('/Volumes/Eskreis-Winkler/RSNAproject/FULL_MATRIX/full_matrix.mat') %this loads database with patient characteristics (e.g. age, BIRADS, BPE, etc)

reader = 0



if reader ==1
    load('/test_results_readerstudy/Y_Lambda2_LR1e-05_D1_E20_B32_F0_X126_U1_M4.mat')
    YY_MAT_U1 = YY_MAT;
    load('/test_results_readerstudy/Y_Lambda2_LR1e-05_D1_E20_B32_F0_X126_U2_M4.mat')
    YY_MAT_U2 = YY_MAT;

    
    load('/test_results_readerstudy/labels_test_Lambda2_LR1e-05_D1_E20_B32_F0_X126_U1_M4.mat')
    Labels_Test_MAT_U1 = Labels_Test_MAT;
    load('/test_results_readerstudy/labels_test_Lambda2_LR1e-05_D1_E20_B32_F0_X126_U2_M4.mat')
    Labels_Test_MAT_U2 = Labels_Test_MAT;

    load('/test_results_readerstudy/patient_id_Lambda2_LR1e-05_D1_E20_B32_F0_X126_U1_M4.mat')
    path_list_U1 = Patient_id_MAT;
    load('/test_results_readerstudy/patient_id_Lambda2_LR1e-05_D1_E20_B32_F0_X126_U2_M4.mat')
    path_list_U2 = Patient_id_MAT;

    
else
    load('/test_results/Y_Lambda2_LR1e-05_D1_E20_B32_F0_X126_U1_M4.mat')
    YY_MAT_U1 = YY_MAT;
    load('/test_results/Y_Lambda2_LR1e-05_D1_E20_B32_F0_X126_U2_M4.mat')
    YY_MAT_U2 = YY_MAT;

    load('/test_results/labels_test_Lambda2_LR1e-05_D1_E20_B32_F0_X126_U1_M4.mat')
    Labels_Test_MAT_U1 = Labels_Test_MAT;
    load('/test_results/labels_test_Lambda2_LR1e-05_D1_E20_B32_F0_X126_U2_M4.mat')
    Labels_Test_MAT_U2 = Labels_Test_MAT;

    load('/test_results/patient_id_Lambda2_LR1e-05_D1_E20_B32_F0_X126_U1_M4.mat')
    path_list_U1 = Patient_id_MAT;
    load('/test_results/patient_id_Lambda2_LR1e-05_D1_E20_B32_F0_X126_U2_M4.mat')
    path_list_U2 = Patient_id_MAT;

end


L1=Labels_Test_MAT_U1;
Y1=YY_MAT_U1;
L2=Labels_Test_MAT_U2;
Y2=YY_MAT_U2;

%this pulls the accession numbers, and identifies the screening breast MR
%exams (i.e. screenlist)
[ACC_list_U1, noscreenlist_U1, screenlist_U1] = get_ACC_from_path(path_list_U1, ACC, recently_diagnosed);
[ACC_list_U2, noscreenlist_U2, screenlist_U2] = get_ACC_from_path(path_list_U2, ACC, recently_diagnosed);

%gets right/left information
[L_list, R_list] = get_laterality_from_path(path_list_U2);
LR_list=L_list+R_list;
LR_list(LR_list<2)=0;
LR_list(LR_list>0)=1;

if reader ==1
    screenlist_U1=ones(size(screenlist_U1));
    screenlist_U2=ones(size(screenlist_U2));
end

% identifies screening MRIs
L1_screen = L1(logical(screenlist_U1),:);
Y1_screen = Y1(logical(screenlist_U1),:);
ACC_list_U1_screen = ACC_list_U1(logical(screenlist_U1));

L2_screen = L2(logical(screenlist_U2),:);
Y2_screen = Y2(logical(screenlist_U2),:);
ACC_list_U2_screen = ACC_list_U2(logical(screenlist_U2));



[sensitivity1, specificity1, accuracy1, SE_sensitivity1,SE_specificity1, SE_accuracy1...
    sensitivityU1, specificityU1, accuracyU1, SE_sensitivityU1,SE_specificityU1, SE_accuracyU1, uLL1,uLLp1, uYY1, uYYr1, uYYpool1, ACC_listuu1]=LY_to_stat_expanded4(L1_screen, Y1_screen, ACC_list_U1_screen);

[sensitivity2_all, specificity2_all, accuracy2_all, SE_sensitivity2_all,SE_specificity2_all, SE_accuracy2_all...
    sensitivityU2_all, specificityU2_all, accuracyU2_all, SE_sensitivityU2_all,SE_specificityU2_all,...
    SE_accuracyU2_all, uLL2_all,uLLp2_all, uYY2_all, uYYr2_all, uYYpool2_all, ACC_listuu2_all]...
    =LY_to_stat_expanded4_perbreast(L2_screen, Y2_screen, ACC_list_U2_screen, ones(size(L_list)), LR_list);



