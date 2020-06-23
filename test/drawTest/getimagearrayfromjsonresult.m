function [im,a ,h,w] =getimagearrayfromjsonresult(jsonfilename,imnumber,slnumber)

data=readanddecodejson(jsonfilename);

a=data.images(imnumber).slice(slnumber).Vr+data.images(imnumber).slice(slnumber).Vi*1i;
h=data.images(imnumber).slice.h;
w= data.images(imnumber).slice.w;

im=zeros(h,w);im(:)=a;  