function [a ,h,w] =getarrayfromresult(data,imnumber,slnumber)

slnumber=1;
a=data.images(imnumber).slice(slnumber).Vr+data.images(imnumber).slice(slnumber).Vi*1i;

h=data.images(imnumber).slice.h;
w= data.images(imnumber).slice.w;