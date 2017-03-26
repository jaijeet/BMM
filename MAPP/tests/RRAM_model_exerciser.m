MOD = RRAM_ModSpec;
check_ModSpec(MOD);

MEO = model_exerciser(MOD);
MEO.display(MEO);

vtb = -2:0.2:2; gap = -0.1:0.1:1.8;   
MEO.plot('itb_fe', vtb, gap, MEO);
MEO.plot('dGap_fi', vtb, gap, MEO); 

% MEO.plot('ditb_fe_dvtb', vtb, s, MEO);
% MEO.plot('ditb_fe_dGap', vtb, s, MEO)
% MEO.plot('ddGap_fi_dvtb', vtb, s, MEO);  
% MEO.plot('ddGap_fi_dGap', vtb, s, MEO);  

