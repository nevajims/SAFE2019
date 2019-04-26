function [equispaced_points_mm,path_length]  = get_outside_edge ( data , height_ , width_ , no_of_points , do_plot); 

horz_mm_p_pix = width_/max(data.x_);
vert_mm_p_pix = height_/max(data.y_);
complex_p                                    =   data.x_+  1i*data.y_            ;
ordered_complex_p                            =   put_points_in_order(complex_p)  ;

if length(complex_p) == length(ordered_complex_p)
path_length                                  =   get_path_length(ordered_complex_p);
ordered_complex_p                            =   [ordered_complex_p;ordered_complex_p(1)] ;
[equispaced_points,equispaced_path_length]   =   get_equispaced_points(path_length(1:1:length(path_length)), ordered_complex_p(1:1:length(path_length)), no_of_points);
equispaced_points_mm                         =  equispaced_points       *  horz_mm_p_pix  ; 
equispaced_path_length_mm                    =  equispaced_path_length  *  horz_mm_p_pix  ; 
equispaced_points_mm                         =  equispaced_points_mm -mean(equispaced_points_mm)  ;
opp_mmm                                      =  (ordered_complex_p- mean(ordered_complex_p)) * horz_mm_p_pix    ;


if do_plot == 1
figure(1)
hold on
subplot(2,1,1)
plot(equispaced_points_mm,'.')
hold on
axis equal
subplot(2,1,2)
plot(opp_mmm(1:10:length(opp_mmm)),'r.')
axis equal 
title(['Horz mm per pixel =' , num2str(horz_mm_p_pix), ', Vert mm per pixel =' , num2str(vert_mm_p_pix),'.']) 
end %if do_plot == 1

else
disp('The ordered points are not the same size as the unordered ones-  investigate the function  ~~put_points_in_order~~ ')
end %if length(complex_p) == length(ordered_complex_p)

end % main function

%----------------------------------------------------------------------------------------------------------
function ordered_complex_p = put_points_in_order(complex_p) ;
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

elseif isempty(find(ordered_indices == sorted_ind(4)))
ordered_indices = [ordered_indices,sorted_ind(4)];    
current_val = complex_p(sorted_ind(4));

else
more_points   = 0;
end
    
end % while more_points ==1
ordered_complex_p =  complex_p(ordered_indices);

end %function ordered_complex_p = put_points_in_order(complex_p);
%----------------------------------------------------------------------------------------------------------
function path_length =  get_path_length(ordered_complex_p);
% path legth (1) = 0
% path legth (2) = dist(1-2)
% path legth (3) = % path legth (2)+ dist(2-3)
% etc
path_length = zeros(1,length(ordered_complex_p));

for index = 2 : length(ordered_complex_p) + 1
if index  ==length(ordered_complex_p) + 1
current_val = ordered_complex_p(1);
else
current_val = ordered_complex_p(index);
end
path_length(index) = path_length(index-1)+  abs(current_val-ordered_complex_p(index-1));
end %for index = 2 : length(ordered_complex_p)
end %function path_length =  get_path_length = (ordered_complex_p);
%----------------------------------------------------------------------------------------------------------
function [equispaced_points,equispaced_path_length]   = get_equispaced_points(path_length, ordered_complex_p, no_of_points); 
distance_per_point = max(path_length)/(no_of_points-1);
% for each path length use a spline to calculate the value
equispaced_points         =  zeros(1,no_of_points);
equispaced_path_length    =  zeros(1,no_of_points);
triple_path_length        =  [path_length(1:length(path_length)-1) - max(path_length) , path_length(1:length(path_length)) , path_length(2:length(path_length)) + max(path_length)];
triple_ordered_complex_p  =  [ordered_complex_p(1:length(ordered_complex_p)-1)' , ordered_complex_p(1:length(ordered_complex_p))' , ordered_complex_p(2:length(ordered_complex_p))'];

for index = 1 : no_of_points 
% find the relavent index
equispaced_path_length(index) =   distance_per_point*(index-1)                                    ;
[dummy,closest_ind] = min(abs((path_length - equispaced_path_length(index))))                     ;
rel_indices =  length(path_length) + closest_ind - 20 : length(path_length) + closest_ind + 20    ;  
% plot(triple_path_length(rel_indices),'.')
% disp (num2str(length(rel_indices)))
equispaced_points(index)      =  -1 * spline(triple_path_length(rel_indices) , triple_ordered_complex_p(rel_indices) , distance_per_point*(index-1));

end %for index = 2 : no_of_points 

end % function
%----------------------------------------------------------------------------------------------------------


