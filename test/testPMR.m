
PMR=CLOUDMR2DPMR('RSS');

L=CLOUDMRRD('/data/MYDATA/DATIPROVA/AC1SLICE_1P5MM.dat');
LN=CLOUDMRRD('/data/MYDATA/DATIPROVA/AC1SLICE_1P5MM_NOISE.dat');
PMR.setSignalKSpace(L.getKSpaceImageSlice(0,1,1,1));
PMR.setNoiseKSpace(LN.getKSpaceImageSlice(0,1,1,1));