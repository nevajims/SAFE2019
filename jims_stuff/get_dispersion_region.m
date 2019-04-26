function [dispersion_region] = get_dispersion_region (reshaped_proc_data , max_freq  ,max_ph_vel)

% need to add the mode shapes to the output structure- and verify that they
% are ordered correctly

do_plot = 1;
minimum_number_of_points_in_curve = 3;
[ind_row,ind_col] = find(reshaped_proc_data.freq <= max_freq*1.1);
freq_ind = [ind_row,ind_col];
[ind_row_2,ind_col_2] = find(reshaped_proc_data.ph_vel <= max_ph_vel*1.1);
ph_vel_ind = [ind_row_2,ind_col_2];
count = 0;
%matching_indices

for index = 1:size(freq_ind,1)
for index_2 = 1:size(ph_vel_ind,1)    
    
if freq_ind(index,1) == ph_vel_ind(index_2,1) && freq_ind(index,2) == ph_vel_ind(index_2,2) 
count = count + 1;    
matching_indices(count,1)=freq_ind(index,1);
matching_indices(count,2)=freq_ind(index,2);
end %if freq_ind(index,1) == ph_vel(index_2,1) && freq_ind(index,2) == ph_vel(index_2,2) 
   
end %for index_2 = 1:size(ph_vel_ind,1)    
end %for index = 1:size(freq_ind,1)
unique_mode_nums =  unique(matching_indices(:,2));

filt_mode_count = 0;
for index = 1:size(unique_mode_nums,1)
   
%unique_mode_name{index} = ['mode ',num2str(unique_mode_nums(index))];
ind_temp =  matching_indices(find(matching_indices(:,2) == unique_mode_nums(index)),1);

if length(ind_temp)>minimum_number_of_points_in_curve
filt_mode_count = filt_mode_count +1;
freq__ {filt_mode_count} = reshaped_proc_data.freq(ind_temp,unique_mode_nums(index));
ph_vel__  {filt_mode_count}  = reshaped_proc_data.ph_vel(ind_temp,unique_mode_nums(index));

unique_mode_numbers(filt_mode_count) =   unique_mode_nums(index);
unique_mode_names{filt_mode_count} =  ['Mode ',num2str(unique_mode_nums(index)),'.'];
end %if length(ind_temp)>2

end %for index = 1:size(unique_mode_nums,1)


dispersion_region.freq              = freq__;
dispersion_region.Vph               = ph_vel__;
dispersion_region.unique_mode_numbers  = unique_mode_numbers;
dispersion_region.mesh = reshaped_proc_data.mesh;
save dispersion_region dispersion_region


colors = 'rgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmyrgbckmy'; 
if do_plot == 1
figure
hold on

for index = 1: size(dispersion_region.freq,2)
plot(dispersion_region.freq{index},dispersion_region.Vph{index},[colors(index),'x-'])    
end %for index = 1: length(dispersion_region.freq)

legend(unique_mode_names,'location','EastOutside')
xlim([0 max_freq])
ylim([0 max_ph_vel])

end %if do_plot = 1

end %function