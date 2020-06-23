cd /data/MYDATA/2018-08-07_BRAINO_scan/
d=dir('*.dat');
A=mapVBVD(d(1).name);
N=mapVBVD(d(2).name);
cd /data/project/mroptimum/MATLABCODE/classes/NEW/

%this test shows how to instantiate an ACM for SNR or for image
%recontrstructions


%% RSS
o.UseCovarianceMatrix=1;
%noise bandwidth
o.NBW=1;
o.subtype="sense"

%instantiate
L1=CLOUDMR2DACMRSS(permute(A.image(),[1 3 2]),permute(N.image(),[1 3 2]),o);



o.UseCovarianceMatrix=0;
o.NBW=1;
%instantiate
L2=CLOUDMR2DACMRSS(permute(A.image(),[1 3 2]),permute(N.image(),[1 3 2]),o);

o.UseCovarianceMatrix=1;
o.NBW=0;
%instantiate
L3=CLOUDMR2DACMRSS(permute(A.image(),[1 3 2]),permute(N.image(),[1 3 2]),o);

o.UseCovarianceMatrix=0;
o.NBW=0;
%instantiate
L4=CLOUDMR2DACMRSS(permute(A.image(),[1 3 2]),permute(N.image(),[1 3 2]),o);

%gest snr
L1.getSNR();
L2.getSNR();
L3.getSNR();
L4.getSNR();
subplot(221);imshow(abs(L1.SNR),[]);title(['SNR NBW=1 COV=1, ' num2str(L1.SNR(256,128))]);
subplot(222);imshow(abs(L2.SNR),[]);title(['SNR NBW=1 COV=0, ' num2str(L2.SNR(256,128))]);
subplot(223);imshow(abs(L3.SNR),[]);title(['SNR NBW=0 COV=1, ' num2str(L3.SNR(256,128))]);
subplot(224);imshow(abs(L4.SNR),[]);title(['SNR NBW=0 COV=0, ' num2str(L4.SNR(256,128))]);

figure()
subplot(221);imshow(abs(L1.getImage()),[]);title(['NBW=1 COV=1, ' ]);
subplot(222);imshow(abs(L2.getImage()),[]);title(['NBW=1 COV=0, ' ]);
subplot(223);imshow(abs(L3.getImage()),[]);title(['NBW=0 COV=1, ' ]);
subplot(224);imshow(abs(L4.getImage()),[]);title(['NBW=0 COV=0, ' ]);



%% B1
clear o;
	

clear L1;
L1=CLOUDMR2DACMB1(permute(A.image(),[1 3 2]),permute(N.image(),[1 3 2]),o);
L1.setSensitivityCalculationMethod('adaptive');
%self
L1.setSourceCoilSensitivityMap(L1.getSignalKSpace);

L1.getSNR();
figure;
subplot(121);imshow(abs(L1.SNR),[]);title(['NBW=1 , adaptive  self' num2str(L1.SNR(256,128))]);
L2=CLOUDMR2DACMB1(permute(A.image(),[1 3 2]),permute(N.image(),[1 3 2]),o);
L2.setSensitivityCalculationMethod('simplesense');
L2.setSourceCoilSensitivityMap(L2.getSignalKSpace);
L2.getSNR();
subplot(122);imshow(abs(L2.SNR),[]);title(['NBW=1 , simplesense  self' num2str(L2.SNR(256,128))]);



%% SENSE
o.NBW=0;
L=CLOUDMR2DACMSENSE(permute(A.image(),[1 3 2]),permute(N.image(),[1 3 2]),o);
L.setSensitivityCalculationMethod('simplesense');
L.setSourceCoilSensitivityMap(L.getSignalKSpace);


%Frequenxy Acceleration
L.AccelerationF=1;

%Phase Acceleration
L.AccelerationP=10;



f=L.getSNR();
subplot(122);imshow(abs(f),[]);title(['NBW=1 , simplesense  self' num2str(f(256,128))]);








%% SENSE with packed kspace data
clear L;
o.NBW=0;

SF=permute(A.image(),[1 3 2]);
S=SF(:,1:4:end,:);

L=CLOUDMR2DACMSENSE(S,permute(N.image(),[1 3 2]),o);
L.setSensitivityCalculationMethod('simplesense');
L.setSourceCoilSensitivityMap(SF);


%Frequenxy Acceleration
L.AccelerationF=1;

%Phase Acceleration
L.AccelerationP=4;



f=L.getSNR();
subplot(122);imshow(abs(f),[]);title(['NBW=1 , simplesense  self' num2str(f(256,128))]);






