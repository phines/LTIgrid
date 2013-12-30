clc
clear all
case24_ieee_rts_Libby
gen=ans.gen
bus=ans.bus
branch=ans.branch

% Ybus=zeros(24,24)
% for k=1:38  %38 rows in gen struct
%     m=branch(k,1);
%     n=branch(k,2);
%     Ybus(m,n)=1/(branch(k,3)+j*branch(k,4));
%     Ybus(n,m)=Ybus(m,n);
%     end
% for k=1:24
%    prim=sum(Ybus(k,:))
%    Shunt=0
%    r=find(branch(:,1)==k|branch(:,2)==k)
%    for m=1:length(r)
%        Shunt=Shunt+(j/2)*(branch(r(m),5))       
%    end
%    Ybus(k,k)=prim+Shunt
% end

n = size(ans.bus,1);
m = size(ans.branch,1);

F=branch(:,1)
T=branch(:,2)
X=branch(:,4)
G=gen(:,1)
ng=length(G)
B=sparse(F,T,-1./X,n,n)+sparse(T,F,-1./X,n,n)+sparse(T,T,1./X,n,n)+sparse(F,F,1./X,n,n)
M=sparse(G,1:ng,1,n,ng)

% build a matrix that estimates the branch power flows, when multiplied by theta:
flow_matrix = sparse((1:m)',F,1./X,m,n) + sparse((1:m)',T,-1./X,m,n); %aka "H" from our meeting notes

% f=
%A=FLOW MATRIX PLUS ZEROES but size?
%b=
Aeq=horzcat(B,M)
beq=-bus(:,3) %Pd
lbtheta=zeros(1,24)
ubtheta=2*pi*ones(1,24) %or inf?
ubtheta(1)=0
lb=(horzcat(lbtheta,(gen(:,10)')))'
ub=(horzcat(ubtheta,(gen(:,9)')))'  %why not 1X48?
