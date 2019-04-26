function [equispaced_points,equispaced_path_length]   = get_equispaced_points(path_length, ordered_complex_p, no_of_points ); 

distance_per_point = max(path_length)/(no_of_points-1);
% for each path length use a spline to calculate the value

equispaced_points      = zeros(1,no_of_points);
equispaced_path_length = zeros(1,no_of_points);

for index = 1 : no_of_points 
    
equispaced_points(index) =     spline(path_length,ordered_complex_p, distance_per_point*(index-1));
equispaced_path_length(index) =   distance_per_point*(index-1);

end %for index = 2 : no_of_points 

end % function

