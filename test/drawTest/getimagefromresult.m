function a=getimagefromresult(data,imnumber)




a=zeros(data.images(imnumber).slice.h, data.images(imnumber).slice.w);a(:)=data.images(imnumber).slice.Vr+data.images(imnumber).slice.Vi*1i