clear all;
ampli=textread('J:\Datasets\Corona\GE_2007-10-02_LV_internal corona 7kV.pdb.A.txt');
phase=textread('J:\Datasets\Corona\GE_2007-10-02_LV_internal corona 7kV.pdb.P.txt');
%times=textread('J:\Universita di Bologna\Papers for modification in code\venkatesh sir 4 feb files\data of epoxy double v\epoxy void_ac test.024.pd2.Ti.txt');
var(:,2)=ampli;
var(:,1)=phase;
var(:,3)=phase;
xlswrite('J:\Datasets\Corona\GE_2007-10-02_LV_internal corona 7kV-rawPQdata.xlsx',var);


