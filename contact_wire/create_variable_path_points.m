
function  [variable_path_length]      =  create_variable_path_points(nominal_increments, equispaced_path_length_mm,radius_of_curvature)

%   works with 80
%  [equispaced_points_mm , equispaced_path_length_mm , path_length,   radius_of_curvature]  = get_outside_edge_variable( data , 10.6 , 10.6 , 80 , 1);


ind_  = find(radius_of_curvature>5);
radius_of_curvature(ind_) = 5.4 ;
ind_  = find(radius_of_curvature<4);
radius_of_curvature(ind_) = 1;
radius_of_curvature(19) = 1;
radius_of_curvature(44) = 1;

path_length_large = [min(equispaced_path_length_mm):max(equispaced_path_length_mm)/10000 : max(equispaced_path_length_mm) ];
radius_of_curvature_large = interp1(equispaced_path_length_mm,radius_of_curvature,path_length_large,'pchip');
ind_ = find(radius_of_curvature_large>=5);
radius_of_curvature_large(ind_) = 5.4;
ind_ =find(radius_of_curvature_large < 5);
radius_of_curvature_large(ind_) = 1;

boundaries_inds = [1,find(abs(diff(radius_of_curvature_large))>1),length(radius_of_curvature_large)];
bound_positions  = path_length_large(boundaries_inds);
rad_curve_vals = [radius_of_curvature_large(boundaries_inds(2:end) -5)];

variable_path_length = [];
for index = 1:length(bound_positions)-1
variable_path_length = [variable_path_length , bound_positions(index):rad_curve_vals(index)*max(path_length_large)/nominal_increments:bound_positions(index+1)];     
end % for index = 1:length(boundaries_inds)

end
