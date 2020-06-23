L='/data/MYDATA/2018-08-07_BRAINO_scan';
d=dir(fullfile(L,'*.dat'));


FRSS='http://epmlcdcdvm01.nyumc.org/APPDATA/114/ACM/J/ACMOPT_5bbe67215d1a8.json';
FSENSE='http://192.168.56.2/APPDATA/74/ACM/J/ACMOPT_5bb7cc64597ba.json';
FB1='192.168.56.2/APPDATA/74/ACM/J/ACMOPT_5bbbb8cb4775e.json';
FB2='http://192.168.56.2/APPDATA/74/ACM/J/ACMOPT_5c9a3857aedec.json';

%% TEST classes RSS

S=fullfile(L, d(1).name);
N=fullfile(L,d(2).name);

p='/data/tmp/100.json';
l='/data/tmp/10033.json';

SNRmat2(S,N,FRSS,'RSS',p,l);



SNRmat2(S,N,FSENSE,'SENSE',p,l);

SNRmat2(S,N,FB1,'B1',p,l);








%% TEST classes RSS 3D

L='/home/montie01/Dropbox/For_Eros/SNR_rawdata_examples/64 channel Prisma data';
d=dir(fullfile(L,'*.dat'));

S=fullfile(L, d(1).name);
N=fullfile(L,d(2).name);

p='/data/tmp/100';
l='/data/tmp/10033.json';

O3=SNRmat2(S,N,F,'RSS',p,l);




