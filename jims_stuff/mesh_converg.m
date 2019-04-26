function mesh_converg(chosen_freqency,do_plot)
% get the Vph at chosen frequncy
% takes data in the form of the structure  'dispersion_region' - should be
% in that directory
% plot for run number rather than element size
close all
no_meshes = 5;  % change this to check the directory for how many are there
conv_results.chosen_freqency = chosen_freqency;
conv_results.ob_length =  3*1E-2; 

for index = 1 : no_meshes;
    
clear dispersion_region
file_name{index} = ['dispersion_region_',num2str(index),'.mat'];
load(file_name{index})
[element_length_stats ] = get_mean_element_length(dispersion_region.mesh);
conv_results.el_len(index) =   element_length_stats.mean_len;
freq_results = get_freq_vals_from_dis_region(dispersion_region,conv_results.chosen_freqency);
conv_results.mode_no{index}   =   freq_results.ir_number   ;
conv_results.vph_vals{index}  =   freq_results.interp_V_ph ;

end %for index = 1 : no_meshes;

% first find the max mode number
current_max = 0;
for index = 1 : length(conv_results.mode_no)
    if max(conv_results.mode_no{index}) > current_max
     current_max = max(conv_results.mode_no{index});   
    end %if max(conv_results.mode_no{index}) > current_max
end %for index = 1 : length(conv_results.mode_no)
max_mode = current_max ;

disp(['max mode = ', num2str(max_mode)])
mode_in_all = ones(1,max_mode);

for index = 1: max_mode
for index_2 = 1:no_meshes    
 if ~length(find (conv_results.mode_no{index_2} ==index))
 mode_in_all(index) = 0;
 end %if length(find (conv_results.mode_no{index_2} ==index))
end %for index_2 = 1:no_meshes        
end %for index = 1: max mode    

common_modes = mode_in_all.*[1:max_mode]              ;
common_modes = common_modes(find(common_modes ~= 0))  ;

for index = 1:length(common_modes)
conv_results.common_modes_leg{index} = ['mode: ',num2str(common_modes(index))];
end %for index = 1:length(common_modes)

% for each mode plot the percentage of the finest mesh
% build up an array of common modes

for index = 1 : no_meshes    
for index_2 = 1 : length(common_modes)
common_vals(index,index_2) =   conv_results.vph_vals{index}(find(conv_results.mode_no{index} == common_modes(index_2)));
end %for index_2 = 1 : length(common_modes)
end %for index = 1 : no_meshes        

for index = 1:size(common_vals,1)
common_vals_divisor(index,:) = common_vals(size(common_vals,1),:);
end %for index = 1:size(common_vals,1)

common_vals_perc = 100*common_vals./common_vals_divisor;
conv_results.common_modes = common_modes;
conv_results.common_vals_perc = common_vals_perc;
conv_results.run_labels =  [1:size(conv_results.el_len,2)];

%save conv_results conv_results
if do_plot ==1
figure(1)
hold on
title(['Convergence, common modes at ',num2str(conv_results.chosen_freqency/1E3),' kHz'])
xlabel('Run Number')
ylabel('% value of the finest mesh')

plot(conv_results.run_labels,conv_results.common_vals_perc,'x-')

set(gca,'XTick',[1:size(conv_results.el_len,2)])

legend(conv_results.common_modes_leg,'location', 'EastOutside' )

end %if do_plot ==1
end% function




function freq_vals  = get_freq_vals_from_dis_region(dispersion_region,selected_freq);
% go through every curve
% ir =   frequency (with)in region
% selected_freq = 0.5E6;   %  for trial purposes
ir_mode_count = 0;

for index = 1: size(dispersion_region.freq,2)
if selected_freq >  min(dispersion_region.freq{index}) && selected_freq <  max(dispersion_region.freq{index})
   
% frequency in range
ir_mode_count = ir_mode_count + 1                                        ;
ir_number(ir_mode_count)  =  dispersion_region.unique_mode_numbers(index);
interp_V_ph(ir_mode_count) = spline(dispersion_region.freq{index} , dispersion_region.Vph{index} , selected_freq);

% now interpolate to find the Vph for this mode
end %if selected_frequency >  min(dispersion_region.freq{1}) && selected_frequency <  max(dispersion_region.freq{1})
end %for index = 1: size(dispersion_region.freq,2)

if ir_mode_count == 0
freq_vals            = 'void' ;
disp('no freqs found')
else
freq_vals.ir_number = ir_number;
freq_vals.interp_V_ph = interp_V_ph;
end %if ir_mode_count == 0

end %function

function [element_length_stats ] = get_mean_element_length(mesh)
node_pos          = mesh.nd.pos(:,1) + 1i*mesh.nd.pos(:,2)   ;
element_nodes     = mesh.el.nds                              ;
nodes_per_element = size(element_nodes,2)                    ;
no_of_elements    = size(element_nodes,1)                    ;
lengths           = zeros(no_of_elements,nodes_per_element)  ;

for index = 1 : no_of_elements
for index_2 = 1: nodes_per_element   
    
point_1 = index_2;

if index_2 == nodes_per_element   
point_2 = 1;
else
point_2 = point_1+1;
end %if index_2 == nodes_per_element   

lengths(index,index_2)  =   abs(node_pos(element_nodes(index,point_1))-node_pos(element_nodes(index,point_2)));
    
end %for index_2 = 1: nodes_per_element   
end %for index = 1 : no_of_elements

element_length_stats.slengths = lengths                                  ;
element_length_stats.mean_len = mean(mean(lengths))                      ;
element_length_stats.std_pc   = 100*std(std(lengths))/mean(mean(lengths));

end %function [element_length_stats ] = get_mean_element_length(mesh)

