temp_fid=fopen('c:\temp\weld data.txt','r');
anum=zeros([5,5]);
for i=1:60
    a=str2num(fgetl(temp_fid));
    anum(1:25)=a(1:25)
    surf(20*log10(anum));
axis tight;
axis off;
shading interp
view(2);
title(int2str(i));
keyboard
end

