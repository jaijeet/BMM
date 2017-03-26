MOD = hys_template_ModSpec;
check_ModSpec(MOD);

MEO = model_exerciser(MOD);
MEO.display(MEO);

vpn = -2:0.2:2; s = -2:0.2:2;   
MEO.plot('ipn_fe', vpn, s, MEO);
MEO.plot('ds_fi', vpn, s, MEO); 

MEO.plot('dipn_fe_dvpn', vpn, s, MEO);
MEO.plot('dipn_fe_ds', vpn, s, MEO)
MEO.plot('dds_fi_ds', vpn, s, MEO);  


