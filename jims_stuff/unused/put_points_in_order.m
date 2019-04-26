function ordered_complex_p = put_points_in_order(complex_p);
% puts points in order around the edge

[current_val , start_ind] = min(complex_p);
ordered_indices = [start_ind] ;  % start off the ordered list 
more_points = 1;

while more_points == 1

dist_to_current = abs((complex_p - current_val));

[sort_v_dummy,sorted_ind] = sort(dist_to_current);
% the first value sorted_ind(1)is the distance to current val(0).
if isempty(find(ordered_indices == sorted_ind(2)))
ordered_indices = [ordered_indices,sorted_ind(2)];
current_val = complex_p(sorted_ind(2));

elseif isempty(find(ordered_indices == sorted_ind(3)))
ordered_indices = [ordered_indices,sorted_ind(3)];    
current_val = complex_p(sorted_ind(3));
else
more_points   = 0;
end
    
end % while more_points ==1
ordered_complex_p =  complex_p(ordered_indices);

end %function ordered_complex_p = put_points_in_order(complex_p);
