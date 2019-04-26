function [in_indices,in_indices_2] = remove_repeated_frequncies(freq , no_wn , tolerance_)
%-------------------------------------------------------------------------
% this method has a problem at the point when the modes are being ordered
%-------------------------------------------------------------------------

points_per_wn = length(freq)/no_wn  ;
in_count = 0                        ;
% get the indices for the first wavenumber and then just repeat them for the rest 

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
