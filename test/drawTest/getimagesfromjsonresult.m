function [IMAGES] =getimagesfromjsonresult(jsonfilename)

data=readanddecodejson(jsonfilename);

for im=1:numel(data.images)
    
    IMAGES{im,2}=data.images(im).imageName;
    IMAGES{im,1}=[];
    for s=1:numel(data.images(im).slice)
    a=data.images(im).slice(s).Vr+data.images(im).slice(s).Vi*1i;
    h=data.images(im).slice(s).h;
    w= data.images(im).slice(s).w;

    IM=zeros(h,w);IM(:)=a;
    IMAGES{im,1}=cat(3,IMAGES{im,1},IM);
    
    end
end