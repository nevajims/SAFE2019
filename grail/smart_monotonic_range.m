function [start_index,end_index,inc]=smart_monotonic_range(f);
[s_inc,e_inc]=max_monotonic_range(f,1);
[s_dec,e_dec]=max_monotonic_range(f,-1);
size_inc=e_inc-s_inc;
size_dec=e_dec-s_dec;
if size_inc>=size_dec;
   start_index=s_inc;
   end_index=e_inc;
   inc=1;
else
   start_index=s_dec;
   end_index=e_dec;
   inc=-1;
end;

   



