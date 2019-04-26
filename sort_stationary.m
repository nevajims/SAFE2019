%function  reshaped_proc_data_np  sort_stationary


% get only the relevant parts using sort
% put the mesh in there
% to sort- two possibilities:
% (1) use the sorting algorythm
% (2) just go through each freq and order bt mag of

%  change modes to be the same as propagating modes

all_strain_per  = unsorted_results{1}.all_strain_per;
cc=hsv(size(all_strain_per  ,2));
icon_ = {'.','o','s','v','o','.'};
figure
hold on
leg_text = '';

unsorted_results_short{1}.all_strain_per = unsorted_results{1}.all_strain_per;

for index = 1:size(all_strain_per  ,2)
   
pos_ind  = find(imag(unsorted_results{index}.waveno)>0.006 & imag(unsorted_results{index}.waveno)<6 ) ;    
disp(length (pos_ind))
unsorted_results_short{index}.freq                 =   unsorted_results{index}.freq(pos_ind);
unsorted_results_short{index}.waveno               =   unsorted_results{index}.waveno(pos_ind);
unsorted_results_short{index}.ms_x                 =   unsorted_results{index}.mode_shapes(find(unsorted_results{index}.dof == 1),pos_ind);  
unsorted_results_short{index}.ms_y                 =   unsorted_results{index}.mode_shapes(find(unsorted_results{index}.dof == 2),pos_ind);
unsorted_results_short{index}.ms_z                 =   unsorted_results{index}.mode_shapes(find(unsorted_results{index}.dof == 3),pos_ind);
% unsorted_results_short{index}.mesh                 =   unsorted_results{index}.mesh;

plot3(unsorted_results{index}.freq(pos_ind) , real(unsorted_results{index}.waveno(pos_ind)), imag(unsorted_results{index}.waveno(pos_ind))   ,icon_{index},'color',cc(index,:));
hold on
if index == size(all_strain_per  ,2)
comma_insert = '';
else
comma_insert = ',';
end
leg_text  = [leg_text,'''','Strain = ',num2str(all_strain_per(index)),'%' ,'''', comma_insert]; 

end %for indx = 1:size(all_strain_per  ,2)

eval(['legend(',leg_text,')'])
xlabel('Frequency')
ylabel('Real Wavenumber')
zlabel('Imaginary Wavenumber')
%zlim([-10,10])
%ylim([-20 20])
zlim([0,5])
ylim([0 20])
xlim([0,300])
view([0 -1 0])
unique_freqs = unique(unsorted_results_short{index}.freq);

for index_strain = 1:size(all_strain_per  ,2)
   
for index = 1:length(unique_freqs)
    
temp_inds = find(unsorted_results_short{index_strain}.freq==unique_freqs(index));
[BB,II] = sort(imag(unsorted_results_short{index_strain}.waveno(temp_inds)));
sorted_temp_inds  =flip(temp_inds(II));

for mode_index = 1:length(sorted_temp_inds)
    
sorted_results{index_strain}.freq(index,mode_index)   = unsorted_results_short{index_strain}.freq(sorted_temp_inds(mode_index)); 
%sorted_results{index_strain}.waveno(index,mode_index) = imag(unsorted_results_short{index_strain}.waveno(sorted_temp_inds(mode_index)));     
sorted_results{index_strain}.waveno(index,mode_index) = unsorted_results_short{index_strain}.waveno(sorted_temp_inds(mode_index));     
sorted_results{index_strain}.ph_vel(index,mode_index) = 2*pi*(sorted_results{index_strain}.freq(index,mode_index))./sorted_results{index_strain}.waveno(index,mode_index);

sorted_results{index_strain}.ms_x(:,index,mode_index) = unsorted_results_short{index_strain}.ms_x(:,sorted_temp_inds(mode_index));     
sorted_results{index_strain}.ms_y(:,index,mode_index) = unsorted_results_short{index_strain}.ms_y(:,sorted_temp_inds(mode_index));     
sorted_results{index_strain}.ms_z(:,index,mode_index) = unsorted_results_short{index_strain}.ms_z(:,sorted_temp_inds(mode_index));     

sorted_results{index_strain}.mesh = mesh;

end % for mode_index = 1:length(sorted_temp_inds)
end %for index = 1:length(unique_freqs)
end% for index_strain = 1::size(all_strain_per  ,2)

fig_A= figure;
suptitle('                      Wave number  Sensititvity') 
hold on
fig_B= figure;
hold on

mode_index = 1;
figure(fig_A)

subplot(2,1,1)
hold on
title('Mode 1')
for index = 1:size(all_strain_per  ,2)
%plot(sorted_results{index}.freq(:,mode_index),   imag(sorted_results{index}.waveno(:,mode_index)),'colr',cc(index,:))    
%plot(sorted_results{index}.freq(:,mode_index),  100* (imag(sorted_results{index}.waveno(:,mode_index))-imag(sorted_results{1}.waveno(:,mode_index))      ) ./imag(sorted_results{1}.waveno(:,mode_index)),'color',cc(index,:))    
plot(sorted_results{index}.freq(:,mode_index),   100*(sorted_results{index}.waveno(:,mode_index) - sorted_results{1}.waveno(:,mode_index)      ) ./sorted_results{1}.waveno(:,mode_index),'color',cc(index,:))    
end %for index = 1:length(unique_freqs)
ylim([0 100])
xlim([0 200])
xlabel('Frequency')
ylabel('Sensitivity (%)')
grid on

figure(fig_B)
suptitle('                       Wave Number')
subplot(2,1,1)
hold on
title('Mode 1')
for index = 1:size(all_strain_per  ,2)
%plot(sorted_results{index}.freq(:,mode_index),   imag(sorted_results{index}.waveno(:,mode_index)),'colr',cc(index,:))    
%plot(sorted_results{index}.freq(:,mode_index),  100* (imag(sorted_results{index}.waveno(:,mode_index))-imag(sorted_results{1}.waveno(:,mode_index))      ) ./imag(sorted_results{1}.waveno(:,mode_index)),'color',cc(index,:))    
plot(sorted_results{index}.freq(:,mode_index),  sorted_results{index}.waveno(:,mode_index),'color',cc(index,:))    
end %for index = 1:length(unique_freqs)
ylim([0 3.5])
xlim([0 200])
xlabel('Frequency (Hz)')
ylabel('Imaginary Wavenumber')
grid on

mode_index = 2;
figure(fig_A)

subplot(2,1,2)
hold on
title('Mode 2')
for index = 1:size(all_strain_per  ,2)
%plot(sorted_results{index}.freq(:,mode_index),   imag(sorted_results{index}.waveno(:,mode_index)),'color',cc(index,:))    
%plot(sorted_results{index}.freq(:,mode_index),   100*(imag(sorted_results{index}.waveno(:,mode_index))-imag(sorted_results{1}.waveno(:,mode_index)))./imag(sorted_results{1}.waveno(:,mode_index)),'color',cc(index,:))    
plot(sorted_results{index}.freq(:,mode_index),   100*(sorted_results{index}.waveno(:,mode_index)-sorted_results{1}.waveno(:,mode_index))./sorted_results{1}.waveno(:,mode_index),'color',cc(index,:))   


end %for index = 1:length(unique_freqs)
ylim([0 100])
xlim([0 200])
eval(['legend(',leg_text,')'])
xlabel('Frequency')
ylabel('sensitivity (%)')
grid on






figure(fig_B)

subplot(2,1,2)
hold on
title('Mode 2')
for index = 1:size(all_strain_per  ,2)
%plot(sorted_results{index}.freq(:,mode_index),   imag(sorted_results{index}.waveno(:,mode_index)),'color',cc(index,:))    
%plot(sorted_results{index}.freq(:,mode_index),   100*(imag(sorted_results{index}.waveno(:,mode_index))-imag(sorted_results{1}.waveno(:,mode_index)))./imag(sorted_results{1}.waveno(:,mode_index)),'color',cc(index,:))    
plot(sorted_results{index}.freq(:,mode_index),   sorted_results{index}.waveno(:,mode_index),'color',cc(index,:))    
end %for index = 1:length(unique_freqs)
ylim([0 3.5])
xlim([0 200])
xlabel('Frequency (Hz)')
ylabel('Imaginary Wavenumber')
eval(['legend(',leg_text,')'])
grid on

% save in a format to allow to display
% all of the sorted results are imag values for waven0

%put data into format for modes
for index = 1:size(all_strain_per  ,2)
reshaped_proc_data_np(index).data = sorted_results{index};
end %for index = 1:size(all_strain_per  ,2)
reshaped_proc_data_np(1).data.all_strain_per = all_strain_per ;
reshaped_proc_data_np(1).data.stat   =   1;

