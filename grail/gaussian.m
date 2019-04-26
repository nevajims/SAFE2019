function x=gaussian(l,pos_fract,size_fract);
r=linspace(0,1,l)-pos_fract;
r1=size_fract/((-log(0.01))^0.5);
x=exp(-(r/r1) .^ 2);
