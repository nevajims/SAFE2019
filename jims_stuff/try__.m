function angle_degrees = try__( freq_vals ,y_vals, chosen_freq)
% function angle_degrees = find_gradiant_angle ( freq_vals ,y_vals, chosen_freq  )
% function angle_degrees = find_gradiant_angle ( freq_vals ,y_vals, chosen_freq,mode_name)
% could pass the mode name in too
find_gradient  = 1; 
freq_increment = 1/length(freq_vals);
temp_freq_diff    =    ( freq_vals - chosen_freq );
close_to_chosen_value =  find(abs(temp_freq_diff) < max(abs(temp_freq_diff))*freq_increment);

if isempty(close_to_chosen_value)
disp ('frequency out of range for this mode')   
angle_degrees = NaN;
find_gradient = 0;
end    

if   max(diff(close_to_chosen_value)) > 1
disp([' There appears to two y values at this value of frequency (index jump =  ',num2str(max(diff(close_to_chosen_value))),')'])      
angle_degrees = NaN;
find_gradient = 0;
end  % if

if find_gradient == 1
[~ , min_index]  = min(abs(temp_freq_diff));
angle_degrees= abs(180/pi* atan((y_vals(min_index) - y_vals(min_index+1))/(freq_vals(min_index)- freq_vals(min_index+1))));
end %if find_gradient == 1

end %function
