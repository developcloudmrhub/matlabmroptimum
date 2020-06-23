function [OUT]=mr_optimumexample_worker(signalname,noisename,optionname,optionstruct,NR,B)
%PUBBLICAZIONE_INVIVO_ANALYSIS_worker(signalname cell array,noisename,optionname,options struct, number rof replica,box)




%roiin,roiiout

N=CLOUDMRRD(noisename);
KSN=CLOUDMRSpreadthenoiseinto2DKSpace(N,true);

if(isempty(optionstruct))
o=CLOUDMRgetOptions(optionname);
else
    o=optionstruct;
end

o.NR=NR;

clear C;
%reconstruct the data
clear S
for s=1:numel(signalname)
    
    C(s)=CLOUDMRgetclassfromOptions(o);
    C(s).setConf(o)
    
    name=signalname{s};
    
    S=CLOUDMRRD(name);
    for sl=1:S.getNumberImageSlices()
        KSS=S.getKSpaceImageSlice(0,1,1,sl);
        if C(s).isAccelerated()
            KSS=undersamplemSense2D(KSS,C(s).AccelerationF,C(s).AccelerationP,C(s).Autocalibration);
        end
        
            C(s).setSignalKSpace(KSS);

        if C(s).needsSensitivity()
                    C(s).setSourceCoilSensitivityMap(KSS);
        end
        C(s).setNoiseKSpace(KSN);
        OUT.DATA(:,:,sl,s)=C(s).getImage();
        OUT.ACM(:,:,sl,s)=C(s).getSNR();
    end
end


OUT.PMR=NaN(size(OUT.ACM));

clear S;
name=signalname{s};
S=CLOUDMRRD(name);

for s=1:numel(signalname)
    for sl=1:S.getNumberImageSlices()
        
        
        
                
            
            
            KSS=S.getKSpaceImageSlice(0,1,1,sl);
        if (isfield(o,'AccelerationP'))
         KSS=undersamplemSense2D(KSS,o.AccelerationF,o.AccelerationP,o.Autocalibration);
        end
            
        
        OUT.PMR(:,:,sl,s)=PUBBLICAZIONE_PMR_worker(KSS,KSN,o);
    end
end

% parfor sl=1:S.getNumberImageSlices()
% KSS=S.getKSpaceImageSlice(1,1,1,sl)
% SNRACM(:,:,sl)=PUBBLICAZIONE_ACM_worker(KSS,KSN,o);
% end

OUT.FAST=PUBBLICAZIONE_FAST_worker(OUT.DATA,2,B,0);

end
