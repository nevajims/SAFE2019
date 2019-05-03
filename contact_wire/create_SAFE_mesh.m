function output_mesh = create_SAFE_mesh( number_points, equispced_variable, do_plot, save_YN  )

% Input Parameters
% number_points                    -   number of points around the edge of the mesh (for variable this is the number if they were all fine spaced)
% equispced_variable               -   1 equispced  2 variable
% do_plot                          -   1 = Yes 
% save_YN                          -   1 = Yes -  saves to    meshes directory  under filename_MESH.mat     (or filename_MESH_2.mat, filename_MESH_3.mat etc when they exist) 


% MESH TWEEKING PARAMETRS ----------------------------------------
% MESH TWEEKING PARAMETRS ----------------------------------------
if number_points< 120
cbv = 3   ;        %    curvature_bound_value
slm = 0.6 ;        %    small_length_multiplier
llm = 4   ;        %    large_length_multiplier

elseif  number_points<250 && number_points >= 120
cbv = 1.5  ;   %    curvature_bound_value
slm = 1  ;     %    small_length_multiplier
llm = 5  ;     %    large_length_multiplier

else
cbv = 0.6;
slm = 1  ;     %    small_length_multiplier
llm = 10  ;    %    large_length_multiplier
end
% MESH TWEEKING PARAMETRS ----------------------------------------
% MESH TWEEKING PARAMETRS ----------------------------------------

input_settings.cbv = cbv ;
input_settings.slm = slm ;
input_settings.llm = llm ;
input_settings.number_points= number_points;
input_settings.equispced_variable = equispced_variable;

triangular_element_type = 2;
cd('raw_profiles')

temp_a      =      dir('AC*.mat')        ;
temp_b      =      {temp_a.name}         ;
choice = listdlg('PromptString' , 'Select the raw profile to mesh' , 'SelectionMode' , 'single'  , 'ListString' , temp_b);
file_name = temp_b{choice};

disp(['Chosen fil... ' , file_name])
load (file_name)
cd('..')
[cw_dimensions.area ,cw_dimensions.width, cw_dimensions.actual] =  get_cw_dimensions (file_name , 1);

% keyboard
% get the points around the edge----------------------------------------

switch(equispced_variable)

    case(1)
 disp('case 1')       
[equispaced_points_mm , path_distance ]  = get_outside_edge( data , cw_dimensions.width , number_points,0);
nom_el_size = 0.5*path_distance * 1E-3;
nd_ = [real(equispaced_points_mm)'*1E-3,imag(equispaced_points_mm)'*1E-3];

mesh_area      = round(  polyarea(real(equispaced_points_mm),imag(equispaced_points_mm))*10) /10 ;
mesh_width     = round(  (max(real(equispaced_points_mm))-min(real(equispaced_points_mm)))*10) /10  ;
   
    case(2)
disp('case 2')    
[variable_points_mm , nom_el_size_mm ]  = get_outside_edge_variable( data , cw_dimensions.width , number_points,cbv,slm,llm,0);
nom_el_size = 0.7*nom_el_size_mm * 1E-3;
nd_ = [real(variable_points_mm)'*1E-3,imag(variable_points_mm)'*1E-3];

mesh_area      =  round(polyarea(real(variable_points_mm),imag(variable_points_mm))*10)/10     ;
mesh_width     =  round((max(real(variable_points_mm))-min(real(variable_points_mm)))*10)/10   ;
end %switch(equispced_variable)

hdata.hmax                     =   nom_el_size;
ops.output                     =   false;

[mesh.nd.pos, mesh.el.nds, mesh.el.fcs] = mesh2d(nd_, [], hdata, ops);
mesh.el.type  = ones(size(mesh.el.nds, 1), 1) * triangular_element_type ;
mesh.nd.dof   = ones(size(mesh.nd.pos, 1), 3)                           ;

output_mesh = mesh;

if do_plot == 1
   
figure('units','normalized','outerposition',[0 0 1 1]);
suptitle(['File Name: ',file_name])
subplot(1,2,1)
fv.Vertices = mesh.nd.pos;
fv.Faces = mesh.el.nds;
patch(fv, 'FaceColor', 'c');
axis equal;
axis off;

title(['#nodes = ',  num2str(length(mesh.nd.pos)),', #elements = ',num2str(length(mesh.el.nds)) ,     ]) 
subplot(1,2,2) 

plot(nd_(:,1),nd_(:,2),'.')
title(['#points: ',num2str(length (nd_))])
axis equal;
axis off;
end %if do_plot == 1

perc_from_actual  =  100* (abs(cw_dimensions.actual - mesh_area))/cw_dimensions.actual;
perc_from_nominal =  100* (abs(cw_dimensions.area - mesh_area))/cw_dimensions.actual;

disp(['mesh area = ',num2str(mesh_area)])     
disp(['mesh width  = ', num2str(mesh_width)])
disp(['% from actual / nominal  = ', num2str( round( perc_from_actual*10)/10  ),'%/',num2str(round(perc_from_nominal*10)/10),'%'])

mesh.details.cw_nom_dimensions     = cw_dimensions   ;
mesh.details.cw_act_dimensions.mesh_area     =    mesh_area    ;
mesh.details.cw_act_dimensions.mesh_width    =    mesh_width   ;
mesh.details.file_name         = file_name       ; 
mesh.details.input_settings    = input_settings  ;

if save_YN == 1
save_file(mesh,file_name)
end%if save_file == 1

end %function output_mesh = create_mesh( input_args )

function save_file(mesh,file_name)
cd('meshes')
if exist ([file_name(1:end-4),'_MESH.mat'])==0 
save([file_name(1:end-4),'_MESH.mat'],'mesh')     
else
dummy = dir([file_name(1:end-4),'_MESH*.mat']);
num_files = length(dummy);    
save([file_name(1:end-4),'_MESH_',num2str(num_files+1),'.mat'],'mesh')     
end %if exist ([file_name(1:end-4),'_MESH']) 
cd('..')

end


function [cw_area,cw_width,cw_actual] =  get_cw_dimensions (file_name,do_plot)

%dimensions
AC_vals      = [80,10.6;100,12.0;107,12.3;120,13.2;150,14.8];
actual_area  =[79.6,100.1,105,120.5,150.8];

dashes_ = find(file_name=='-')  ;
dots_ = find(file_name=='.')    ;
start_ind =  dashes_(1) + 1;

if  dots_(1) > 7
spaces_ = find(file_name==' ');
end_ind = spaces_(1) - 1;
else  
end_ind = dots_(1) - 1;
end

cw_area = str2num(file_name(4:6));
row_ = find(AC_vals(:,1) == cw_area);
cw_width = AC_vals(row_ ,2);
cw_actual =  actual_area( row_);

if do_plot == 1
disp(['(Nom Area, Act Area, Width) = (',num2str(cw_area),',',num2str(cw_width),',',num2str(cw_actual),')'])
end %if do_plot == 1

end

%-----------------------------------------------
% Get equispaced points  
%-----------------------------------------------

function [equispaced_points_mm , path_distance ]      = get_outside_edge( data , width_ , no_of_points , do_plot) 

horz_mm_p_pix = width_/(max(data.x_)- min(data.x_))                                                 ;
vert_mm_p_pix =horz_mm_p_pix                                                       ;

complex_p                                    =   data.x_ +  1i * data.y_            ;
ordered_complex_p                            =   put_points_in_order(complex_p)     ;

% if length(complex_p) == length(ordered_complex_p)
path_length                                  =   get_path_length(ordered_complex_p);
ordered_complex_p                            =   [ordered_complex_p;ordered_complex_p(1)] ;
[equispaced_points,equispaced_path_length]   =   get_equispaced_points(path_length(1:1:length(path_length)), ordered_complex_p(1:1:length(path_length)), no_of_points);
equispaced_points_mm                         =   equispaced_points       *  horz_mm_p_pix  ;
equispaced_path_length_mm                    =   equispaced_path_length  *  horz_mm_p_pix  ; 
equispaced_points_mm                         =   equispaced_points_mm -mean(equispaced_points_mm)  ;
opp_mmm                                      =   (ordered_complex_p- mean(ordered_complex_p)) * horz_mm_p_pix    ;
path_distance                                =   mean(diff(equispaced_path_length_mm));



if do_plot == 1
figure
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

% else
%disp('The ordered points are not the same size as the unordered ones-  investigate the function  ~~put_points_in_order~~ ')
%disp([num2str( length(complex_p)),'/',num2str( length(ordered_complex_p))])
% end %if length(complex_p) == length(ordered_complex_p)

end 

function ordered_complex_p                            = put_points_in_order(complex_p)
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

function path_length                                  =  get_path_length(ordered_complex_p)
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

function [variable_points_mm , path_distance ]        = get_outside_edge_variable( data , width_ , no_variable_points,cbv,slm,llm, do_plot) 

disp ('correct file')
no_of_points = no_variable_points;
%no_of_points = 100;

% need a multiplier  for the dense parts of the mesh
% First   need the curvature at any point along the length
% run through twice-  (1) at 80 spacing for the radius of curvature (2) at
% desired spacing for the variable (using the bulk value)

horz_mm_p_pix                                =   width_/max(data.x_)                                ;
vert_mm_p_pix                                =   horz_mm_p_pix                                      ;
complex_p                                    =   data.x_ +  1i * data.y_                            ;

% size(complex_p)

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

[variable_path_length_mm]                    =  create_variable_path_points(no_variable_points, equispaced_path_length_mm,radius_of_curvature,cbv,slm,llm);  %  only works with no_of_points=80   at tthe moment

variable_path_length                         =   variable_path_length_mm/horz_mm_p_pix;

[variable_points]                            =   get_variable_points(path_length(1:1:length(path_length)), ordered_complex_p(1:1:length(path_length)),variable_path_length);

variable_points_mm                           =   variable_points * horz_mm_p_pix ;
 
path_distance                                =   max(diff(variable_path_length_mm));



%keyboard
if do_plot == 1
figure
plot(variable_points_mm,'.-')
axis equal 

end %if do_plot == 1

end 

function [radius_of_curvature,curv_error]             =  get_radius_of_curvature(equispaced_points_mm)

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
% points_ = [equispaced_points_mm(index-2),equispaced_points_mm(index-1),equispaced_points_mm(index),equispaced_points_mm(index+1),equispaced_points_mm(index+2)];    

points_ = [equispaced_points_mm(index-3), equispaced_points_mm(index-2),equispaced_points_mm(index-1),equispaced_points_mm(index),equispaced_points_mm(index+1),equispaced_points_mm(index+2),equispaced_points_mm(index+3)];    


end %switch(index)
%*************************************************************************************************** 
% [radius_of_curvature(index) ,~] = fit_circle_through_3_points(three_points);

is_collinear = check_is_collinear([real(points_(1)), real(points_(5)),  real(points_(7))] , [imag(points_(1)), imag(points_(5)),  imag(points_(7))]);
if is_collinear
radius_of_curvature(index) = inf;
curv_error(index) = 1; 
   
else
[radius_of_curvature(index) , curv_error(index)]     =      circfit(real(points_) , imag(points_));
end %if is_collinear

% disp(num2str( radius_of_curvature(index)))
% if radius_of_curvature(index) == Inf; radius_of_curvature(index) = NaN;end


end %for index = 1: length(ordered_complex_p)

end %function radius_of_curvature                          =   get_radius_of_curvature(ordered_complex_p);

function[variable_points]                             =   get_variable_points(path_length, ordered_complex_p , variable_path_length)

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

function  is_collinear                                = check_is_collinear(x_vals,y_vals)
% use three points 
% Formula for area of triangle is : 

tol = 0.0001;
area_of_triangle = 0.5 *  abs(x_vals(1) * (y_vals(2) - y_vals(3)) + x_vals(2) * (y_vals(3) - y_vals(1)) + x_vals(3) * (y_vals(1) - y_vals(2)));
if   area_of_triangle < tol;  is_collinear = 1 ; else is_collinear = 0 ; end    

end %function  is_collinear = check_is_collinear(x_vals,y_vals )

function  [variable_path_length]                      =  create_variable_path_points(nominal_increments, equispaced_path_length_mm,radius_of_curvature,cbv,slm,llm)

%   works with 80
%   [equispaced_points_mm , equispaced_path_length_mm , path_length,   radius_of_curvature]  = get_outside_edge_variable( data , 10.6 , 10.6 , 80 , 1);


ind_                      = find(radius_of_curvature>=cbv)   ;
radius_of_curvature(ind_) = 5                              ;
ind_                      = find(radius_of_curvature<5)    ;
radius_of_curvature(ind_) = 1                              ;
radius_of_curvature(19)   = 1                              ;
radius_of_curvature(44)   = 1                              ;

base_path_difs        = slm * mean(diff(equispaced_path_length_mm));  % this is used for the high curvature areas 
%middle_path_difs      =  

wide_base_path_difs   = mean(diff(equispaced_path_length_mm))* llm;


path_length_large = [min(equispaced_path_length_mm):max(equispaced_path_length_mm)/10000 : max(equispaced_path_length_mm) ];
radius_of_curvature_large = interp1(equispaced_path_length_mm,radius_of_curvature,path_length_large,'pchip');

ind_ = find(radius_of_curvature_large >= 5);
radius_of_curvature_large(ind_) = 5;
ind_ =find(radius_of_curvature_large < 5);
radius_of_curvature_large(ind_) = 1;

boundaries_inds = [1,find(abs(diff(radius_of_curvature_large))>1),length(radius_of_curvature_large)];
bound_positions  = path_length_large(boundaries_inds);
rad_curve_vals   = [radius_of_curvature_large(boundaries_inds(2:end) - 5)];
variable_path_length = [];



% calculate the base path length as the equispaced path length

% take each region and find the path length boundaries 
% and the total path length of that region   
% divide that by the nominal path length
% of it-   put one point
% at the start 

for index = 1:length(bound_positions)-1

segment_length = bound_positions(index + 1)  -  bound_positions(index);

switch(rad_curve_vals(index))
    case(5)    
number_of_divisions = ceil(segment_length / wide_base_path_difs);
path_gap =    segment_length/number_of_divisions;
    case(1)
number_of_divisions = ceil(segment_length / base_path_difs);
path_gap =    segment_length/number_of_divisions;
end %for index = 1:length(bound_positions)-1
variable_path_length =  [variable_path_length , bound_positions(index) : path_gap : bound_positions(index+1)-path_gap];
%variable_path_length = [variable_path_length , bound_positions(index) : rad_curve_vals(index)* max(path_length_large)/nominal_increments : bound_positions(index+1)];     

 end % for index = 1:length(boundaries_inds)

end




