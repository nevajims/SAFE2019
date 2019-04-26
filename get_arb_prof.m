temp           =    imread('arb2.png');

a =(temp(:,:,1)+temp(:,:,2)+ temp(:,:,3));
non_zer     =    find(a>0);
a(non_zer)  =  250;

%figure('bw','k')

image(a)

