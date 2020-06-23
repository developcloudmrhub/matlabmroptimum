function a=createimageandplot(originalArray,h,w,plotaxes,debugaxes,minreductionpercentage,maxreductionpercentage,supplementaxes)







 

originalArray=real(originalArray);

LUT=jet(512);

% axes(debugaxes);
%
%
% hold off
% hist(originalArray(:));
%
% hold on
% plot([0 255],[min(originalArray(:)) max(originalArray(:))],'r')
%
%
% hold off


%   var buffer = new Uint8Array(width * height * 4);

buffer0=NaN(h*w,1);
buffer1=NaN(h*w,1);

buffer2=NaN(h*w,1);



%         //    console.log(B);
%         if (isUndefined(B)){
%             var B=data.GetMaxMin();
%         };


%VIEWER MEAN MAX
VIEWERMAX256.Min=1;

VIEWERMAX256.Max=256;



%         var b2={Max: parseFloat(brightness.Max),Min:parseFloat(brightness.Min)};

%IMAGE reduction
reduction.Min=minreductionpercentage;
reduction.Max=maxreductionpercentage;

%
%         //const _this = this;
%
%         var X= getLUTboundaries(B,b2);


IMAGEMAXANDMIN.Min=min(originalArray);
IMAGEMAXANDMIN.Max=max(originalArray);

% this function give me the point
XGRAYSCALEBOUNDARY= getgrayscalemageboundaries(IMAGEMAXANDMIN,reduction, 100);


%
%
%         var Y={Max:255,Min:0};
%
%
%         var FIT=linearfit2pts({x:X.Min,y:Y.Min},{x:X.Max,y:Y.Max});
%


P0.x=XGRAYSCALEBOUNDARY.Min;
P0.y=VIEWERMAX256.Min;


P1.x=XGRAYSCALEBOUNDARY.Max;
P1.y=VIEWERMAX256.Max;

FIT=linearfit2pts(P0,P1);






%         console.log("GOT the fit");
%
%
%         console.log("FIT is");
%         console.log(FIT);
%
%         var m=FIT.m;
%         var q=FIT.q;



m=FIT.m;
q=FIT.q;

%
%         var L={};
%
%
%         //            _/- or -\_
%         if (FIT.m>=0){L.Min=Y.Min,L.Max=Y.Max}else{L.Min=Y.Max,L.Max=L.Min};


%          //            _/- or -\_
if (FIT.m>=0)
    SATURATIONBAND.Min=VIEWERMAX256.Min;
    SATURATIONBAND.Max=VIEWERMAX256.Max;
    
    
    for y=[0:h-1]
    for x=[0:w-1]
        
        pos = (y * w + x)+1;
        g=originalArray(pos);
        
        if (g<XGRAYSCALEBOUNDARY.Min ||isnan(g))
            transformedArray(pos)=SATURATIONBAND.Min;
        end
        
        if (g>XGRAYSCALEBOUNDARY.Max)
            transformedArray(pos)=SATURATIONBAND.Max;
        end
        
        
        if (g<=XGRAYSCALEBOUNDARY.Max && g>=XGRAYSCALEBOUNDARY.Min)
            transformedArray(pos)=ceil((m*g)+q);
            
        end
        
         V2=(transformedArray(pos)*2);
         
         
         try 
                    buffer0(pos,:) = 255*LUT(V2,1);
                    buffer1(pos,:) = 255*LUT(V2,2);
                    buffer2(pos,:) = 255*LUT(V2,3);
         catch
%              display([num2str(V2) ' ' num2str(x) ' ' num2str(y) ]);
         end
        
    end
    
    end


    
    
else
%      -\_
    SATURATIONBAND.Min=VIEWERMAX256.Max;
    SATURATIONBAND.Max=VIEWERMAX256.Min;
    
    
      for y=[0:h-1]
    for x=[0:w-1]
        
        pos = (y * w + x)+1;
        g=originalArray(pos);
        
        if (g<XGRAYSCALEBOUNDARY.Max ||isnan(g))
            transformedArray(pos)=SATURATIONBAND.Min;
        end
        
        if (g>XGRAYSCALEBOUNDARY.Min)
            transformedArray(pos)=SATURATIONBAND.Max;
        end
        
        
        if (g>=XGRAYSCALEBOUNDARY.Max && g<=XGRAYSCALEBOUNDARY.Min)
            transformedArray(pos)=ceil((m*g)+q);
            
        end
        
       
         
         
         try 
               V2=(transformedArray(pos)*2);
                    buffer0(pos,:) = 255*LUT(V2,1);
                    buffer1(pos,:) = 255*LUT(V2,2);
                    buffer2(pos,:) = 255*LUT(V2,3);
         catch
             display([num2str(V2) ' ' num2str(x) ' ' num2str(y) ]);
             
         end
        
    end
    
      end

    
      
end





%             for(var x = 0; x < width; x++) {





axes(debugaxes);
scatter(originalArray,transformedArray);
hold on;
plot(P0.x,P0.y,'r*');

text(P0.x,P0.y-20,num2str(P0.x));

plot(P1.x,P1.y,'r*');
text(P1.x,P1.y+20,num2str(P1.x));
hold off;

ylim([-30 300])
axes(plotaxes);
imshow(cat(3,reshape(buffer0,h,w),reshape(buffer1,h,w),reshape(buffer2,h,w)));



figure(supplementaxes);
scatterhist(originalArray,transformedArray);

end

function FIT=linearfit2pts(p0,p1)
M= (p1.y-p0.y)/(p1.x-p0.x);
M2= (-M*p0.x)+p0.y;

FIT.q=M2;
FIT.m=M;

display(FIT)
polyfit([p0.x p1.x],[p0.y p1.y],1)


end





%
% var getLUTboundaries=function(Ra,bq){
%     //real values, diminuzione
%     //get the range
%     console.log("calc boundaruies");
%
%     var R=Math.abs(Ra.Max-Ra.Min);
%     //get the reduction
%     var D={Max:bq.Max*R/255,Min:bq.Min*R/255};
%     // get the new X values
%     //  console.log(D);
%     return{Max:Ra.Max-D.Max,Min:Ra.Min+D.Min};
%
% };




function O=getgrayscalemageboundaries(realvalue,realdeltavalue,VIEWERRANGE)
% from the original min and max of the image move a percentage of that


RANGE=abs(realvalue.Max-realvalue.Min);

D.Max=realdeltavalue.Max*RANGE/VIEWERRANGE;
D.Min=realdeltavalue.Min*RANGE/VIEWERRANGE;

O.Max=realvalue.Max-D.Max;
O.Min=realvalue.Min+D.Min;

end