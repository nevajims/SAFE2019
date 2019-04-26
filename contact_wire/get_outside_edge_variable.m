function [variable_points_mm , path_distance ]  = get_outside_edge_variable( data , height_ , width_ , no_variable_points, do_plot) 

no_of_points = 80;
% need a multiplier  for the dense parts of the mesh
% First   need the curvature at any point along the length

% run through twice-  (1) at 80 spacing for the radius of curvature (2) at
% desired spacing for the variable (using the bulk value)


horz_mm_p_pix                                =   width_/max(data.x_)                                ;
vert_mm_p_pix                                =   height_/max(data.y_)                               ;
complex_p                                    =   data.x_ +  1i * data.y_                            ;

size(complex_p)
ordered_complex_p                            =   put_points_in_order(complex_p)                     ;
ordered_complex_p                            =   ordered_complex_p(1:1:length(ordered_complex_p))   ;


path_length                                  =   get_path_length(ordered_complex_p);

ordered_complex_p                            =   [ordered_complex_p;ordered_complex_p(1)] ;

[equispaced_points,equispaced_path_length]   =   get_equispaced_points(path_length(1:1:length(path_length)), ordered_complex_p(1:1:length(path_length)), no_of_points);

equispaced_points_mm                         =   equispaced_points       *  horz_mm_p_pix ;
equispaced_points_mm                         =   equispaced_points_mm - mean(equispaced_points_mm) ;

equispaced_path_length_mm                    =   equispaced_path_length  *  horz_mm_p_pix ; 
[radius_of_curvature,~]                      =   get_radius_of_curvature(equispaced_points_mm);

opp_mmm                                      =   (ordered_complex_p- mean(ordered_complex_p)) * horz_mm_p_pix ;

path_distance                                =   mean(diff(equispaced_path_length_mm)) ;

[variable_path_length_mm]                       =  create_variable_path_points(no_variable_points, equispaced_path_length_mm,radius_of_curvature);  %  only works with          no_of_points=80   at tthe moment
variable_path_length                       =   variable_path_length_mm/horz_mm_p_pix;

[variable_points]                            =   get_variable_points(path_length(1:1:length(path_length)), ordered_complex_p(1:1:length(path_length)),variable_path_length);
variable_points_mm                             = variable_points * horz_mm_p_pix ;
 
path_distance                                =   mean(diff(variable_path_length_mm));



%keyboard
if do_plot == 1
figure (1)
plot(equispaced_points_mm,'.-')
axis equal

%figure (2)
%plot(opp_mmm,'g.')
%hold on
%axis equal 
 
figure(2)
plot(variable_points_mm,'.-')
axis equal 

end %if do_plot == 1

% else
%disp('The ordered points are not the same size as the unordered ones-  investigate the function  ~~put_points_in_order~~ ')
%disp([num2str( length(complex_p)),'/',num2str( length(ordered_complex_p))])
% end %if length(complex_p) == length(ordered_complex_p)

end 

%----------------------------------------------------------------------------------------------------------
function ordered_complex_p = put_points_in_order(complex_p) 
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

elseif isempty(find(ordered_indices == sorted_ind(5)))
ordered_indices = [ordered_indices,sorted_ind(5)];    
current_val = complex_p(sorted_ind(5));

elseif isempty(find(ordered_indices == sorted_ind(6)))
ordered_indices = [ordered_indices,sorted_ind(6)];    
current_val = complex_p(sorted_ind(6));

elseif isempty(find(ordered_indices == sorted_ind(7)))
ordered_indices = [ordered_indices,sorted_ind(7)];    
current_val = complex_p(sorted_ind(7));

elseif isempty(find(ordered_indices == sorted_ind(8)))
ordered_indices = [ordered_indices,sorted_ind(8)];    
current_val = complex_p(sorted_ind(8));

elseif isempty(find(ordered_indices == sorted_ind(9)))
ordered_indices = [ordered_indices,sorted_ind(9)];    
current_val = complex_p(sorted_ind(9));

else
more_points   = 0;
end


end % while more_points ==1
ordered_complex_p =  complex_p(ordered_indices);

end %function ordered_complex_p = put_points_in_order(complex_p);
%----------------------------------------------------------------------------------------------------------
function path_length =  get_path_length(ordered_complex_p)
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

function [equispaced_points,equispaced_path_length]   = get_equispaced_points(path_length, ordered_complex_p, no_of_points) 

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


function [radius_of_curvature,curv_error]  =  get_radius_of_curvature(equispaced_points_mm)

%figure(8)
%plot(equispaced_points_mm)
%axis equal

radius_of_curvature = zeros(size(equispaced_points_mm));
curv_error          = zeros(size(equispaced_points_mm));

for index = 1: length(equispaced_points_mm)
    
switch(index)
    
    case(1)
points_ = [equispaced_points_mm(length(equispaced_points_mm)-2),equispaced_points_mm(length(equispaced_points_mm)-1),equispaced_points_mm(length(equispaced_points_mm)),equispaced_points_mm(1),equispaced_points_mm(2),equispaced_points_mm(3),equispaced_points_mm(4)];    

    case(2)
points_ = [equispaced_points_mm(length(equispaced_points_mm)-1),equispaced_points_mm(length(equispaced_points_mm)),equispaced_points_mm(1),equispaced_points_mm(2),equispaced_points_mm(3),equispaced_points_mm(4),equispaced_points_mm(5)];    

    case(3)

points_ = [equispaced_points_mm(length(equispaced_points_mm)),equispaced_points_mm(1),equispaced_points_mm(2),equispaced_points_mm(3),equispaced_points_mm(4),equispaced_points_mm(5),equispaced_points_mm(6)];    


    case(length(equispaced_points_mm))
points_ = [equispaced_points_mm(length(equispaced_points_mm)-3),equispaced_points_mm(length(equispaced_points_mm)-2),equispaced_points_mm(length(equispaced_points_mm)-1), equispaced_points_mm(length(equispaced_points_mm)),equispaced_points_mm(1),equispaced_points_mm(2),equispaced_points_mm(3)];    

    case(length(equispaced_points_mm)-1)
points_ = [equispaced_points_mm(length(equispaced_points_mm)-4), equispaced_points_mm(length(equispaced_points_mm)-3),equispaced_points_mm(length(equispaced_points_mm)-2), equispaced_points_mm(length(equispaced_points_mm)-1), equispaced_points_mm(length(equispaced_points_mm)),equispaced_points_mm(1),equispaced_points_mm(2)];    
   
    case(length(equispaced_points_mm)-2)    
points_ = [equispaced_points_mm(length(equispaced_points_mm)-5),equispaced_points_mm(length(equispaced_points_mm)-4), equispaced_points_mm(length(equispaced_points_mm)-3),equispaced_points_mm(length(equispaced_points_mm)-2), equispaced_points_mm(length(equispaced_points_mm)-1), equispaced_points_mm(length(equispaced_points_mm)),equispaced_points_mm(1)];    

    otherwise        
points_ = [equispaced_points_mm(index-2),equispaced_points_mm(index-1),equispaced_points_mm(index),equispaced_points_mm(index+1),equispaced_points_mm(index+2)];    

end %switch(index)



% [radius_of_curvature(index) ,~] = fit_circle_through_3_points(three_points);

[temp1,temp2]     =      circfit(real(points_) , imag(points_));

radius_of_curvature(index) = temp1;
curv_error(index)          = temp2;

%disp(num2str( radius_of_curvature(index)))
% if radius_of_curvature(index) == Inf; radius_of_curvature(index) = NaN;end

end %for index = 1: length(ordered_complex_p)

end %function radius_of_curvature                          =   get_radius_of_curvature(ordered_complex_p);

%function fill_missing(arr)
%ind = find (isnan(arr)==1)
%end

function[variable_points]           =   get_variable_points(path_length, ordered_complex_p , variable_path_length)

%distance_per_point = max(path_length)/(no_of_points-1);
% for each path length use a spline to calculate the value

variable_points         =  zeros(1,length(variable_path_length));

triple_path_length        =  [path_length(1:length(path_length)-1) - max(path_length) , path_length(1:length(path_length)) , path_length(2:length(path_length)) + max(path_length)];

triple_ordered_complex_p  =  [ordered_complex_p(1:length(ordered_complex_p)-1)' , ordered_complex_p(1:length(ordered_complex_p))' , ordered_complex_p(2:length(ordered_complex_p))'];


for index = 1 : length(variable_path_length)
    
% find the relavent index

[dummy,closest_ind] = min(abs((path_length - variable_path_length(index))))                     ;

rel_indices =  length(path_length) + closest_ind - 20 : length(path_length) + closest_ind + 20    ;  
% plot(triple_path_length(rel_indices),'.')
% disp (num2str(length(rel_indices)))
variable_points(index)      =  -1 * spline(triple_path_length(rel_indices) , triple_ordered_complex_p(rel_indices) , (variable_path_length(index))    );

end %for index = 2 : no_of_points 

variable_points = [variable_points,variable_points(1)];

end




