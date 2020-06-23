function [OUT]=mr_optimum_example()
load CONF.mat
somedefine


%addpath(genpath('/home/montie01/Dropbox/offline/toolboxematlab2'))
addpath(genpath('/data/project/mroptimum/MATLABCODE/'))
addpath(genpath('..'))

PT='./'; %where you want to store the data

signalname{1}=downloadfromcloudmr(PT,'meas_MID01481_FID318481_gre_snrSIGNAL1.dat');
signalname{2}=downloadfromcloudmr(PT,'meas_MID01491_FID318491_gre_snrSIGNAL2.dat');
noisename=downloadfromcloudmr(PT,'meas_MID01493_FID318493_gre_noiseNOISE.dat');

  
%   for m=1:8
            m=2 %bart sum of squares
      clear o;
      optionname=[];
            o=CLOUDMRgetOptions(METHODS(m).MRtype);
            if ~isempty(METHODS(m).ACCF)
                o.AccelerationP=METHODS(m).ACCF;
                o.Autocalibration=METHODS(m).AC;
            end
            OUT=mr_optimumexample_worker(signalname,noisename,optionname,o,100,9);
            
%   end
        




end





function out=downloadfromcloudmr(PT,filename)
filelink=fullfile('http://cloudmrhub.com/RESOURCES',filename);
out=fullfile(PT,filename);
if(~(exist(out,'file')))
    websave(filename,filelink);
end
    
end