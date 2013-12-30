clc
clear all
case24_ieee_rts_Libby
%case3_ps
gencost=ans.gencost;
busdata=ans.bus
gendata=ans.gen
%X=0:1:1000;
figure(1);clf;
hold on

cmap = hsv(size(gendata,1));  %# Creates a 6-by-3 set of colors from the HSV colormap
X=zeros(200,size(gendata,1));
for i = 1:size(gendata,1)   
   x=gendata(i,10):1:gendata(i,9);
   y=(gencost(i,5)).*x.^2+(gencost(i,6)).*x+(gencost(i,7)); %include x^2?
   plot(x,y,'.-','Color',cmap(i,:));  %# Plot each column with a
                                               %#   different color
   X(1:length(x),i)=x;
   
end
xlabel('Power (MW)')
ylabel('Cost($/hr)')
figure(2);clf;
hold on
YP=zeros(50,size(gendata,1));
for i = 1:size(gendata,1)   
    x=gendata(i,10):1:gendata(i,9)
    Yp=2*(gencost(i,5)).*x+(gencost(i,6)) 
    plot(x,Yp,'.-','Color',cmap(i,:));  %# Plot each column with a
                                               %#   different color
    YP(1:length(Yp),i)=Yp;                                           
end
 
xlabel('Power (MW)')
ylabel('Inc. Cost($/MWh)')


Lambdamin=0
Lambdamax=max(max(YP))
Lambdamean=(Lambdamin+Lambdamax)/2
Pgsum=0;
Pdsum=sum(busdata(:,3))
Acc_Diff=0.001
while abs(Pgsum-Pdsum)>Acc_Diff
    Pgsum=0;
    for i=1:size(gendata,1)
        Yp=YP(:,i);
        if max(Yp)<=Lambdamean
            Pgsum=Pgsum+max(X(:,i));
        elseif  max(Yp)>Lambdamean && min(Yp(Yp>0))<=Lambdamean
            pg=(Lambdamean-(gencost(i,6)))/(2*gencost(i,5));
            Pgsum=Pgsum+pg;
        elseif min(Yp(Yp>0))>Lambdamean
            Pgsum=Pgsum+min(Yp(Yp>0));
        else
            disp('WTF')
        end        
    end
    if abs(Pgsum-Pdsum)<=Acc_Diff
        Lambdamean
    elseif Pgsum>Pdsum
        Lambdamax=Lambdamean
        Lambdamean=(Lambdamin+Lambdamax)/2
    elseif Pgsum<Pdsum
        Lambdamin=Lambdamean
        Lambdamean=(Lambdamin+Lambdamax)/2
    else
        disp('WTF')
    end
end


%% Why are there 6 (Pmin10pmax50) that are SO cheap?
%% Are all on...as in, do I include all mins
    
