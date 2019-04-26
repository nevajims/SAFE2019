function exper_format_data = compare_with_experiment(reshaped_proc_data, all_freq_HZ,method_ ,do_plot )
transducer_positions_m  = [0,0.3,0.6,0.9,1.2,1.5,1.8,2.1,2.4,2.7,3.0,3.3] ;
modes_to_plot = [1,2,3];
Load_list_kN =  reshaped_proc_data(1).data.Load_list_kN;
mod_names ={'L0','V0','T0','A0'};
 

%go through each mode 
%for each freq get the corresponding wave number  put fre vs wavenmber
% into a new data -  calculate phase shift in deg / m

for index = 1: length(modes_to_plot)
for index_2 = 1: length(Load_list_kN ) 
for index_3 = 1:length( all_freq_HZ)

waveno_temp       = spline(reshaped_proc_data(index_2).data.freq(:,index),reshaped_proc_data(index_2).data.waveno(:,index),all_freq_HZ(index_3));
phase_vel_temp    = spline(reshaped_proc_data(index_2).data.freq(:,index),reshaped_proc_data(index_2).data.ph_vel(:,index),all_freq_HZ(index_3));

exper_format_data{index}.wn_m(index_2,index_3)                =    waveno_temp      ;    
exper_format_data{index}.ph_vel(index_2,index_3)              =    phase_vel_temp   ;    
exper_format_data{index}.freq_deg_per_sec(index_2,index_3)    =    all_freq_HZ(index_3)*360;

end % for index_3 = 1:length( all_freq_HZ)
end % for index_2 = 1: length(Load_list_kN ) 
end % for index = 1: length(modes_to_plot)
% plot one figure per freq   -     each has the 3 modes in it so 3 subplots

if do_plot ==1

colormap hsv;
cmap = colormap;

for figure_index = 1 : length( all_freq_HZ)
fig_label{figure_index} = figure('units','normalized','outerposition',[0 0 1 1]);
suptitle([num2str(all_freq_HZ(figure_index)),' Hz, method: ',num2str(method_),])

for subplot_index = 1:length(modes_to_plot)   
figure(fig_label{figure_index})
subplot(length(modes_to_plot),1,subplot_index)
title(['                     Mode:',num2str(subplot_index),', (',mod_names{subplot_index},')'])
xlabel('Position (m)')
ylabel('Phase angle (degrees)')
hold on

leg_text = '';
for axial_load_index = 1 : length(Load_list_kN )
% method 1    
wave_number_temp =  exper_format_data{subplot_index}.wn_m(axial_load_index,figure_index);
degrees_per_m    =  360 * wave_number_temp ; 
phase_vals_temp = degrees_per_m * transducer_positions_m ;
% method 1 

% method 2
phase_vel_m_per_s_temp   =  exper_format_data{subplot_index}.wn_m(axial_load_index,figure_index);
freq_deg_per_s_temp      =  exper_format_data{subplot_index}.freq_deg_per_sec(axial_load_index,figure_index);

degrees_per_m_meth_2     =  freq_deg_per_s_temp/phase_vel_m_per_s_temp;
phase_vals_temp_2        =  degrees_per_m_meth_2 * transducer_positions_m ;

% c

Plot_color = cmap(round((axial_load_index /length(Load_list_kN ))*length(cmap)),:); 

switch (method_)
    case(1)    
plot(transducer_positions_m , phase_vals_temp,'o-','Color',Plot_color)
    case(2)
plot(transducer_positions_m , phase_vals_temp_2,'o-','Color',Plot_color)
end %switch (method_)



% now creat each line n of data
if axial_load_index ==length(Load_list_kN )
   comma_insert='';
else
   comma_insert=',';
end %if axial_load_index ==length(Load_list_kN )

leg_text = [leg_text,'''' num2str(Load_list_kN(axial_load_index)),' kN''',comma_insert];

end %for axial_load_index = 1 : length(Load_list_kN )

eval(['lgd = legend(', leg_text,');'])
set(lgd,'FontSize',14)
set(lgd,'Position',[0.9 0.4 0.07 0.2])
% now plot all the loads for that freq

end %for subplot_index = 1:   


end % for figure_index = 1 : length( all_freq_HZ)
end % if do_plot ==1

end % function compare_with_experiment(reshaped_proc_data)