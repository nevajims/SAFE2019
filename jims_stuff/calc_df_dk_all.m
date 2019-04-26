function [gr_vel_all] = calc_df_dk_all(freq_all,wn_all,gap,points_for_spline_fit)
%
%
do_plot = 1;  % temp to make sure its working
gr_vel_all = zeros(size(freq_all));

for mode_index = 1 : size(freq_all,2) % for all modes

freq_ = freq_all(:,mode_index); 
wn_   = wn_all  (:,mode_index);

s_(1) = 0;
for index = 1: size(freq_,1)-1
s_(index + 1) = s_(index) + sqrt((freq_(index)-freq_(index+1))^2  + (wn_(index)-wn_(index+1))^2);       
end %for index = 1: size(freq_,1)
s_ = s_' ;

for index = 1: size(freq_,1)
    
if  points_for_spline_fit == -1  
    
    index_region = [1:size(freq_,1)];
else    
    if index <= points_for_spline_fit
    index_region = [1:index + points_for_spline_fit];    
    elseif  size(freq_,1) - index <= points_for_spline_fit
    index_region = [index- points_for_spline_fit:size(freq_,1)];    
    else
    index_region = [index- points_for_spline_fit : index + points_for_spline_fit];        
    end
end %if  points_for_spline_fit == -1  



df_ds(index)     =  (spline(s_(index_region) ,freq_(index_region)  , s_(index) + gap/2) - spline(s_,freq_ , s_(index) - gap/2))/gap ;
dwn_ds(index)    =  (spline(s_(index_region) ,wn_  (index_region)  , s_(index) + gap/2) - spline(s_,wn_   , s_(index) - gap/2))/gap ;
end  % for index = 1: size(freq_,1)


df_dwn           =   df_ds./dwn_ds ;
df_dk  = df_dwn' ;  %  this is what disperse gives (units check)
gr_vel_ = df_dk *2*pi ;
gr_vel_all(:,mode_index) = gr_vel_;

end % for mode_index = 1 : size(reshaped_proc_data.freq,2) % for all modes



if do_plot ==1
figure    
hold on
title(['points for spline fit = ',num2str(points_for_spline_fit),', gap = ',num2str(gap)])
plot(freq_all,gr_vel_all,'.-')
end %if do_plot ==1    

end %function


