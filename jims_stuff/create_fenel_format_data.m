function [data_wn,unsorted_results] = create_fenel_format_data (unsorted_results)

% there is  definately a problem with 'sort by frequency' function
%-----------------------------------------------
% fields of data:
%-----------------------------------------------
% no_files: 398
% files_exists: 1        - not used
% nodes: [463x3 double]  - not used
% els: [384x4 double]    - not used 
% no_files: 398
% freq: [7960x1 double]  -
% ph_vel: [7960x1 double]
% ms_x: [463x7960 double]
% ms_y: [463x7960 double]
% ms_z: [463x7960 double]
% data.nodes
% modes = 7960 / 398 = 20
% remove results where WN == 0
%-----------------------------------------------
tolerance_ = 0.1;  % for removing repeats
remove_repeats = 0;  % removing in this way doest work when the modes are being ordered with the dot procuct method
sort_by_ascending_freq = 1;

unsorted_results = remove_zero_wn(unsorted_results)                                           ;
%unsorted_results = remove_complex_freqs(unsorted_results)                                    ;

unique_wn      =   size(unique(unsorted_results.waveno),2)                                    ;
points_per_wn  =   length(unsorted_results.waveno)/size(unique(unsorted_results.waveno),2)    ;
freq_          =   abs(unsorted_results.freq)'                                                ;

%ph_vel_       =   real(2*pi*freq_./unsorted_results.waveno')                                 ;
waveno_         =  unsorted_results.waveno';

data_wn.no_files     =   unique_wn                                                            ;
all_dof      = unsorted_results.dof;

if sort_by_ascending_freq ==1
sorted_indices =  sort_by_ascendng_freq(freq_ , unique_wn , points_per_wn)                    ;
freq         =   freq_(sorted_indices);
waveno       =   waveno_(sorted_indices);
all_ms       =   unsorted_results.mode_shapes(:,sorted_indices);
ms_x         =   unsorted_results.mode_shapes(find(unsorted_results.dof == 1),sorted_indices);  
ms_y         =   unsorted_results.mode_shapes(find(unsorted_results.dof == 2),sorted_indices);
ms_z         =   unsorted_results.mode_shapes(find(unsorted_results.dof == 3),sorted_indices);

else
    
freq         =   freq_  ;
waveno       =   waveno_;
all_ms       =   unsorted_results.mode_shapes(:,:);
ms_x         =   unsorted_results.mode_shapes(find(unsorted_results.dof == 1),:);  
ms_y         =   unsorted_results.mode_shapes(find(unsorted_results.dof == 2),:);
ms_z         =   unsorted_results.mode_shapes(find(unsorted_results.dof == 3),:);    
end %if sort_by_ascending_freq ==1

if remove_repeats == 1;
% this is not in use at present

[in_indices] = remove_repeated_frequncies(freq , unique_wn , tolerance_)                    ;    
data_wn.freq         =   freq(in_indices)       ;
data_wn.waveno       =   waveno(in_indices)     ;
data_wn.ph_vel       =   2*pi*data_wn.freq./data_wn.waveno                                    ;
data_wn.ms_x = ms_x(:,in_indices);
data_wn.ms_y = ms_y(:,in_indices);
data_wn.ms_z = ms_z(:,in_indices);

else
data_wn.freq   = freq                              ;
data_wn.waveno = waveno                            ;
data_wn.ph_vel = 2*pi*data_wn.freq./data_wn.waveno ;
data_wn.ms_x = ms_x;
data_wn.ms_y = ms_y;
data_wn.ms_z = ms_z;
data_wn.all_dof      = all_dof;
data_wn.all_ms       = all_ms;

end %if repeats

end %function






function sorted_indices =  sort_by_ascendng_freq(freq_ , unique_wns , points_per_wn);
sorted_indices = zeros(size(freq_));

for index = 1:unique_wns
current_start_index  = 1 + points_per_wn   * (index-1) ;
current_end_index    = points_per_wn       * (index)   ;

[junk, local_ind]    = sort(freq_(current_start_index:current_end_index )); 
sorted_indices(current_start_index:current_end_index) =  local_ind + (index-1) * points_per_wn; 
end %for index = 1:unique_wns

end




function new_unsorted_results = remove_zero_wn(unsorted_results);
[pants, non_zero_index] = find(unsorted_results.waveno~=0);
new_unsorted_results.freq        = unsorted_results.freq(non_zero_index)  ;
new_unsorted_results.waveno      = unsorted_results.waveno(non_zero_index);
new_unsorted_results.mode_shapes = unsorted_results.mode_shapes(:,non_zero_index);
new_unsorted_results.dof         = unsorted_results.dof ;
new_unsorted_results.nd          = unsorted_results.nd  ;
end

function [in_indices,in_indices_2] = remove_repeated_frequncies(freq , no_wn , tolerance_)

points_per_wn = length(freq)/no_wn  ;
in_count = 0                        ;
% get the indices for the first wn and then just repeat them for the rest 

for index = 1 : no_wn
if index == 1
ppw_count = 0;    
    for index_2 = 1:points_per_wn
    current_index =   (index-1) * points_per_wn + index_2;
    if index_2 == 1
    in_count       = in_count + 1 ;
    ppw_count = ppw_count+1;
    in_indices   (in_count)    =    current_index ;
    in_indices_2 (in_count)    =    index_2       ;
    previous_val =  freq(current_index);
    else
    current_val = freq(current_index);
    diff_ = (current_val-previous_val)/previous_val;      
    if  diff_ > tolerance_
    in_count                =    in_count + 1  ;        
    ppw_count = ppw_count+1;
    in_indices(in_count)    =    current_index ;
    in_indices_2 (in_count)    =    index_2       ;
    previous_val = current_val;
    else        
    % dont add to incount
    end
    end %if index_2 ==1
    end    %for index_2 = 1:points_per_wn
%in_indisp(num2str(ppw_count))    
end % if index ==1

if index ~=1    
%clear index_2
for index_2 = 1:ppw_count    
cur_index =   (index-1)*ppw_count + index_2;
in_indices(cur_index)   = in_indices(index_2)+(index-1)*points_per_wn;
in_indices_2(cur_index) = in_indices(index_2);
end%for index_2 = 1:ppw_count    
 
end %if index ~=1    

end %for index = 1 : no_wn
in_indices = in_indices';
in_indices_2 = in_indices_2';
end %function

function   new_unsorted_results = remove_complex_freqs(unsorted_results)    

[pants, non_complex_index ]=  find (imag(unsorted_results.freq)==0);
new_unsorted_results.freq        = unsorted_results.freq(non_complex_index)  ;
new_unsorted_results.waveno      = unsorted_results.waveno(non_complex_index);
new_unsorted_results.mode_shapes = unsorted_results.mode_shapes(:,non_complex_index);
new_unsorted_results.dof         = unsorted_results.dof ;
new_unsorted_results.nd          = unsorted_results.nd  ;

end
