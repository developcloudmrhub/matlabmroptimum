cd /data/2018-08-07_BRAINO_scan/
d=dir('*.dat');
A=mapVBVD(d(1).name); %image
M=mapVBVD(d(2).name); %noise
cd /data/project/mroptimum/MATLABCODE/classes/NEW/

%this test shows how to instantiate an ACM for SNR or for image
%recontrstructions

im=permute(A.image(),[1 3 2]);
si=permute(M.image(),[1 3 2]);



orig = [0 0 ]';
sp = [1 1 ]';
orient = eye(2);
s=[size(im,1) size(im,2)];

S=VectorImageType(s,orig,sp,orient);
S.data=reshape(im(:,:,1),s(1),s(2));
S.datax=reshape(im(:,:,2),s(1),s(2));
S.datay=reshape(im(:,:,3),s(1),s(2));
S.dataz=reshape(im(:,:,4),s(1),s(2));
write_mhd('~/S.mhd',S )


N=VectorImageType(s,orig,sp,orient);
S.data=reshape(si(:,:,1),s(1),s(2));
S.datax=reshape(si(:,:,2),s(1),s(2));
S.datay=reshape(si(:,:,3),s(1),s(2));
S.dataz=reshape(si(:,:,4),s(1),s(2));
write_mhd('~/N.mhd',N )
