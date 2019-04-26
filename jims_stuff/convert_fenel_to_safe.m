function [reshaped_proc_data]   = convert_fenel_to_safe(do_plot)

if (nargin == 0) ; do_plot  = 1 ; end
dir_   = dir('*.mat');
file_choices = {dir_.name};

[temp_val,ok]              =          listdlg('PromptString','Select Fenel file to convert:','SelectionMode','single','ListString',file_choices);

if ok ==1
    
load(file_choices{temp_val});
variable_names            =  {'data_mode_start_indices','data_freq','data_ph_vel','data_ms_x','data_ms_y','data_ms_z','data_nodes','data_els'}   ;

variable_check_ok         = 1                                                                                                                    ;

for index = 1:length(variable_names)
if  exist(variable_names{index},'var')~=1
disp(['Error: ',variable_names{index},' does not exist '])    
variable_check_ok = 0;
end %if  exist(variable_names{index},'var')~=1
end %for index = 1:length(variable_names)

if variable_check_ok ==1
    
data_mode_start_indices(length(data_mode_start_indices)) = data_mode_start_indices(length(data_mode_start_indices))+1;
    
reshaped_proc_data.freq    = ones(length(data_freq)/(length(data_mode_start_indices)-1), length(data_mode_start_indices)-1);
reshaped_proc_data.ph_vel  = ones(size(reshaped_proc_data.freq));
reshaped_proc_data.waveno  = ones(size(reshaped_proc_data.freq));
reshaped_proc_data.ms_x    = ones(size(data_ms_x,1), length(data_freq)/(length(data_mode_start_indices)-1), length(data_mode_start_indices)-1);
reshaped_proc_data.ms_y    = ones(size(reshaped_proc_data.ms_x));
reshaped_proc_data.ms_z    = ones(size(reshaped_proc_data.ms_x));

data_waveno = 2*pi*(data_freq./data_ph_vel);

for index = 1: length(data_mode_start_indices)-1
    
reshaped_proc_data.freq(:,index)    = data_freq(data_mode_start_indices(index):data_mode_start_indices(index+1)-1);
reshaped_proc_data.ph_vel(:,index)  = data_ph_vel(data_mode_start_indices(index):data_mode_start_indices(index+1)-1);  
reshaped_proc_data.waveno(:,index)  = data_waveno(data_mode_start_indices(index):data_mode_start_indices(index+1)-1);

reshaped_proc_data.ms_y(:,:,index)  = complex(data_ms_x(:,data_mode_start_indices(index):data_mode_start_indices(index+1)-1)) ;
reshaped_proc_data.ms_x(:,:,index)  = complex(data_ms_y(:,data_mode_start_indices(index):data_mode_start_indices(index+1)-1)) ;
reshaped_proc_data.ms_z(:,:,index)  = complex(data_ms_z(:,data_mode_start_indices(index):data_mode_start_indices(index+1)-1)) ;

end %for index = 1: length(data_mode_start_indices)-1

%data_els_2  = [data_els(:,1), data_els(:,2),data_els(:,4),data_els(:,3)];
%corrected_elements  =  put_elements_in_clockwise_direction(data_nodes , data_els_2);

corrected_elements  =  put_elements_in_clockwise_direction(data_nodes , data_els)  ;

reshaped_proc_data.mesh.nd.pos  = [data_nodes(:,2), data_nodes(:,1),data_nodes(:,3)];
reshaped_proc_data.mesh.nd.pos(:,1) = reshaped_proc_data.mesh.nd.pos(:,1)-mean(reshaped_proc_data.mesh.nd.pos(:,1));
reshaped_proc_data.mesh.nd.pos(:,2) = reshaped_proc_data.mesh.nd.pos(:,2)-mean(reshaped_proc_data.mesh.nd.pos(:,2));
reshaped_proc_data.mesh.nd.pos(:,3) = reshaped_proc_data.mesh.nd.pos(:,3)-mean(reshaped_proc_data.mesh.nd.pos(:,3));

reshaped_proc_data.mesh.el.nds  = corrected_elements;

save reshaped_proc_data reshaped_proc_data

if do_plot ==1
figure;
fv.Vertices = reshaped_proc_data.mesh.nd.pos;
fv.Faces = reshaped_proc_data.mesh.el.nds;
%fv.Faces = [reshaped_proc_data.mesh.el.nds(:,1)   ];

patch(fv, 'FaceColor', 'c');
axis equal;
axis off;
end %if do_plot ==1

else
disp('variable check failed - cannot process')
end %if variable_check_ok ==1
end %if ok ==1

end %function

function corrected_elements  =  put_elements_in_clockwise_direction( nodes_ , elements_ )
% go through each element and give it the same direction
% whenever direction is swapped- flag it up 

clockwise_count           =    0                    ;
anti_clockwise_count      =    0                    ;
corrected_elements        = zeros(size(elements_))  ; 

for element_index = 1:size(elements_,1)
    
%for element_index = 1:5

current_element =  elements_(element_index,:);
node_positions = nodes_(current_element,1:2);

[~ , bot_left_indices]  = min((abs(node_positions(:,1) - min(node_positions(:,1)))   + abs(node_positions(:,2)-min(node_positions(:,2))) ));
[~ , top_left_indices]  = min((abs(node_positions(:,1) - min(node_positions(:,1)))   + abs(node_positions(:,2)-max(node_positions(:,2)))));
[~ , top_right_indices] = min((abs( node_positions(:,1) - max(node_positions(:,1)))   + abs(node_positions(:,2)-max(node_positions(:,2)))));
[~ , bot_right_indices] = min((abs( node_positions(:,1) - max(node_positions(:,1)))   + abs(node_positions(:,2)-min(node_positions(:,2)))));


new_element_order_indices =  [bot_left_indices , top_left_indices , top_right_indices , bot_right_indices] ;            

if top_right_indices > top_left_indices
clockwise_count = clockwise_count + 1;    
else
anti_clockwise_count = anti_clockwise_count + 1;    
end %if top_right_indices > top_left_indices

for index = 1: size(elements_ ,2)
corrected_elements(element_index,index) = elements_(element_index, new_element_order_indices(index));
end %for index = 1: size(elements_ ,2)    

end %for element_index = 1:size(data_els,1)    
disp([num2str(size(elements_,1)),' elements: ', num2str(clockwise_count) ,' clockwise, ', num2str(anti_clockwise_count) ,' anti-clockwise.'] )
end  %function corrrected_data_els  =  try__(data_nodes,data_els)

% ----------------------------------
% Fenel data that is used:
% ----------------------------------
% data_mode_start_indices -  the start index for each mode : 1:21 double
% data_freq               -  7960 x 1;  -  needs to be split up into each mode
% data_ph_vel
% data_ms_x               -  463x7960 double -  needs to be split up into each mode
% data_ms_y               -  
% data_ms_z               -    
% data_nodes   -  gives x y and z  -  remove z  (463 x 3)
% data_els    (384 x 4)
% ----------------------------------

% ----------------------------------
% Reshaped proc data is as follows:
% ----------------------------------
%      freq: [99x40 double]
%      ph_vel: [99x40 double]
%      waveno: [99x40 double]
%      ms_x: [302x99x40 double]
%      ms_y: [302x99x40 double]
%      ms_z: [302x99x40 double]
%      mesh: [1x1 struct]

%reshaped_proc_data.mesh
%    matl: {[1x1 struct]}- don't need
%    nd: [1x1 struct]
%    el: [1x1 struct]

%reshaped_proc_data.mesh.matl{1}:     - don't need
%    name : 'steel'                   - don't need
%    stiffness_matrix : [6x6 double]  - don't need
%    density : 7932                   - don't need

%reshaped_proc_data.mesh.nd
%    pos: [302x2 double] 
%    dof: [302x3 double] 

%reshaped_proc_data.mesh.el
%     nds:  [484x3 double]   
%     fcs:  [1x1 struct] - don't need
%     matl: [484x1 double] - don't need
%     type: [484x1 double] - don't need
% ----------------------------------



