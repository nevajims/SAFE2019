function [min_index,max_index]=calc_bandwidth(half_spec,db_down);
%returns indexes of points where half spectrum (i.e. to Nyquist freq only)
%climbs more than dB_down below peak value (working in from ends
%This function does not interpolate xx
%work out freq limits
max_val=0;
pts=length(half_spec);
for count=1:pts;
   if abs(half_spec(count))>max_val;
      max_val=abs(half_spec(count));
   end;
end;
%min freq
min_index=1;
while min_index<=pts;
   if abs(half_spec(min_index))>max_val/(10^(db_down/20));
      break;
   end;
   min_index=min_index+1;
end;
%max freq
max_index=pts;
while max_index>=1;
   if abs(half_spec(max_index))>max_val/(10^(db_down/20));
      break;
   end;
   max_index=max_index-1;
end;
