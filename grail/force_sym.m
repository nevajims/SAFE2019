function y=force_sym(x);
if size(x,1)~=size(x,2);
   y=x;
   return;
end;
y=zeros(size(x));
sz=size(x,1);
for count=1:sz;
   y(count,count:sz)=0.5*(x(count,count:sz)+x(count:sz,count)');
   y(count:sz,count)=0.5*(x(count,count:sz)'+x(count:sz,count));
end;
return;
   