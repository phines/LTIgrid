%% Econ with Linprog for 3 bus
%% x = linprog(f,A,b,Aeq,beq,lb,ub)

%% change costs and try again
clc
clear all

All_Load            = importdata('load.mat');
One_Day             = All_Load{133}; %% choose one random day's load
One_Day_Hour_Chunks = One_Day(1:12:end)*.02; %scaled to fit current Pmax's



%%

ps        = case3_ps;
%ps       = case6ww_lk;
gencost   = ps.gencost;
busdata   = ps.bus;
gendata   = ps.gen;
%Pdsum    = sum(busdata(:,3));
PgSS      = [One_Day_Hour_Chunks(1)*3;One_Day_Hour_Chunks(1)*3];
    
cmap = hsv(size(gendata,1));
figure (1);clf;      
hold on
for i=1:size(gendata,1)
   x=gendata(i,10):1:gendata(i,9);
   y=(gencost(i,5)).*x.^2+(gencost(i,6)).*x+(gencost(i,7));
   plot(x,y,'.-','Color',cmap(i,:))
end
figure(2);clf;
hold on
for i = 1:size(gendata,1)   
    x=gendata(i,10):1:gendata(i,9);
    Yp=2*(gencost(i,5)).*x+(gencost(i,6)); 
    plot(x,Yp,'.-','Color',cmap(i,:));                                         
end


f   = gencost(:,6);
A   = [1 0;-1 0;0 1;0 -1];
%A   = [1 0 0;-1 0 0;0 1 0;0 -1 0;0 0 1;0 0 -1];
Aeq = ones(1,size(gendata,1));
Lb  = gendata(:,10);
Ub  = gendata(:,9);
Pgs = zeros(length(One_Day_Hour_Chunks),size(gendata,1));
RRu = gendata(:,22);
RRd = -RRu;

for i=1:length(One_Day_Hour_Chunks)
    
    if  i == 1
        b = [RRu(1)+PgSS(1);RRd(1)+PgSS(1);RRu(2)+PgSS(2);RRd(2)+PgSS(2)];
        %b = [RRu(1);RRd(1);RRu(2);RRd(2);RRu(3);RRd(3)]; %%can't make this inifinite, is this why Will's won't work?
    else
        b = [RRu(1)+Pgs(i-1,1);RRd(1)+Pgs(i-1,1);RRu(2)+Pgs(i-1,2);RRd(2)+Pgs(i-1,2)];
        %b = [RRu(1)+Pgs(i-1,1);RRd(1)+Pgs(i-1,1);RRu(2)+Pgs(i-1,2);RRd(2)+Pgs(i-1,2);RRu(3)+Pgs(i-1,3);RRd(3)+Pgs(i-1,3)];
    end
    
    Beq      = One_Day_Hour_Chunks(i);
    Pgs_curr = linprog(f,A,b,Aeq,Beq,Lb,Ub);
    Pgs(i,:) = Pgs_curr';
end

Pgsum = sum(Pgs,2)
libb=(Pgsum-One_Day_Hour_Chunks)