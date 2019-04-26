function [start_index,end_index]=max_monotonic_range(f,inc);
f=f(:)';
len=length(f);
if inc>0;
   v=f(1:len-1)<f(2:len);
else
   v=f(1:len-1)>f(2:len);
end;
v=[0,v,0];
s=(~v(1:len))&v(2:len+1);
e=v(1:len)&(~v(2:len+1));
si=find(s);
ei=find(e);
%catch for purely monotonic functions (therefore no direction changes)
if isempty(si);
   start_index=1;
   %but still need to check overall direction
   if ((f(len)>=f(1))&(inc>0))|((f(len)<=f(1))&(inc<0))
      end_index=len;
   else
      end_index=1;
   end;
   return;
end;
%check for a couple of errors - should by not used
if length(si)~=length(ei)
   disp('Error - inconsistent vector lengths - setting indexes to unity');
   start_index=1;
   end_index=1;
   return;
end;
[temp,ii]=max(ei-si);
if (ii<1)|(ii>len);
   disp('Error - range check - setting indexes to unity');
   start_index=1;
   end_index=1;
   return;
end;
%final answer
start_index=si(ii);
end_index=ei(ii);