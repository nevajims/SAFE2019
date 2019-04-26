function [aa] =   plot_specific_mode(reshaped_proc_data);

%------------------------------------------------------------------------------------------------------------------------------
% have three views of the mode shape using assymetrical sub plots
% 2d animation
% isometric view
%------------------------------------------------------------------------------------------------------------------------------
% verificaction with 2mm cylinder-  mode shapes and dispesion curves against disperse results
% length dim view
%
% plot the outside of the mesh only
% start to work on the animation
% investigate inheritance of data
%------------------------------------------------------------------------------------------------------------------------------

plot_data_structure.undeformed_node_positions    =  put_node_positions_in_3space(reshaped_proc_data.mesh.nd.pos)   ;
plot_data_structure.element_nodes                =  reshaped_proc_data.mesh.el.nds                                 ;
plot_data_structure.mult_factor                  =  1                                                              ;
plot_data_structure.fig_handle                   =  figure(1)                                                      ;
plot_data_structure.dispersion_axis              =  subplot(2,1,1)                                                 ;

plot_data_structure.mesh_axis                    =  subplot(2,1,2)                                                 ;  
plot_data_structure.continue_                    =  1                      ;


plot_data_structure.point_index                  =  1                      ;     %initial values to be selected
plot_data_structure.reshaped_proc_data           =  reshaped_proc_data     ;
plot_data_structure.xlim_                        = [0 , 0.15E5]            ;
plot_data_structure.ylim_                        = [0 , 10000]             ;
%plot_data_structure.xlim_                        = [0 , inf]              ;
%plot_data_structure.ylim_                        = [0 , inf]              ;
plot_data_structure.xlabel_                      = 'Freq(Hz)'              ;
plot_data_structure.ylabel_                      = 'Phase Velocity(m/s)'   ;
%------------------------------------------------------------------------------------------------------------------------------




plot_dispersion_curves(plot_data_structure.reshaped_proc_data.freq,plot_data_structure.reshaped_proc_data.ph_vel,plot_data_structure.dispersion_axis,plot_data_structure.xlim_,plot_data_structure.ylim_,plot_data_structure.xlabel_,plot_data_structure.ylabel_)

plot_a_mesh(plot_data_structure.undeformed_node_positions, plot_data_structure.fig_handle , plot_data_structure.mesh_axis , plot_data_structure.element_nodes , 'r' );
% continue_ = 1;
% while continue_ == 1

plot_data_structure.slider_handle_1 = uicontrol('Style', 'slider', 'Min',1,'Max',1000000,'Value',1000,'Position',[20 20 120 20],'Callback',@slider_func_1);
set(plot_data_structure.slider_handle_1, 'UserData' , plot_data_structure)

plot_data_structure.button_handle_1 = uicontrol('Style', 'pushbutton', 'String', 'Choose point','Position', [100 100 100 20],'Callback',@but_func_1);       
set(plot_data_structure.button_handle_1, 'UserData' , plot_data_structure)
end %function plot_specific_mode_(reshaped_proc_data )
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function slider_func_1 (hObject, evt)
new_value =  get(hObject,'Value');
plot_data_structure =  get(hObject, 'UserData');  % get the plot data;
%disp(num2str(new_value))
plot_data_structure.mult_factor  = new_value ;

cla(plot_data_structure.mesh_axis  )


plot_a_mesh(plot_data_structure.undeformed_node_positions, plot_data_structure.fig_handle , plot_data_structure.mesh_axis , plot_data_structure.element_nodes , 'r' );

plot_data_structure.deformed_node_positions = get_deformed_node_positions(plot_data_structure.undeformed_node_positions,plot_data_structure.reshaped_proc_data.ms_x(:,plot_data_structure.point_index,...
plot_data_structure.mode_index)  ,  plot_data_structure.reshaped_proc_data.ms_y(:,plot_data_structure.point_index,plot_data_structure.mode_index)  ,...
plot_data_structure.reshaped_proc_data.ms_z(:,plot_data_structure.point_index,plot_data_structure.mode_index) ,   plot_data_structure.mult_factor);

plot_a_mesh(plot_data_structure.deformed_node_positions, plot_data_structure.fig_handle , plot_data_structure.mesh_axis , plot_data_structure.element_nodes , 'g' );


%plot_data_structure.mult_factor
set(plot_data_structure.button_handle_1, 'UserData',plot_data_structure);
set(plot_data_structure.slider_handle_1, 'UserData',plot_data_structure);
end

function  but_func_1(hObject, evt)
%disp(['Selecting a point'])
plot_data_structure = get(hObject, 'UserData'); % get the plot data
axes(plot_data_structure.dispersion_axis);
[selected_freq,slected_pv, plot_data_structure.button_] = ginput(1);

plot_dispersion_curves(plot_data_structure.reshaped_proc_data.freq,plot_data_structure.reshaped_proc_data.ph_vel,plot_data_structure.dispersion_axis,plot_data_structure.xlim_,plot_data_structure.ylim_,plot_data_structure.xlabel_,plot_data_structure.ylabel_)

[plot_data_structure.mode_index ,plot_data_structure.point_index] = find_closest_index(plot_data_structure.reshaped_proc_data.freq, plot_data_structure.reshaped_proc_data.ph_vel , selected_freq , slected_pv,plot_data_structure.xlim_,plot_data_structure.ylim_);
plot(plot_data_structure.reshaped_proc_data.freq(plot_data_structure.point_index,plot_data_structure.mode_index) ,plot_data_structure.reshaped_proc_data.ph_vel(plot_data_structure.point_index,plot_data_structure.mode_index),'o','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',10)
title(['Current mode selected: Mode ',num2str(plot_data_structure.mode_index) ,', Point ',num2str(plot_data_structure.point_index) ],'FontSize',18) 

cla(plot_data_structure.mesh_axis  )
plot_a_mesh(plot_data_structure.undeformed_node_positions, plot_data_structure.fig_handle , plot_data_structure.mesh_axis , plot_data_structure.element_nodes , 'r' );

plot_data_structure.deformed_node_positions = get_deformed_node_positions(plot_data_structure.undeformed_node_positions,plot_data_structure.reshaped_proc_data.ms_x(:,plot_data_structure.point_index,...
plot_data_structure.mode_index)  ,  plot_data_structure.reshaped_proc_data.ms_y(:,plot_data_structure.point_index,plot_data_structure.mode_index)  ,...
plot_data_structure.reshaped_proc_data.ms_z(:,plot_data_structure.point_index,plot_data_structure.mode_index) ,   plot_data_structure.mult_factor);
plot_a_mesh(plot_data_structure.deformed_node_positions, plot_data_structure.fig_handle , plot_data_structure.mesh_axis , plot_data_structure.element_nodes , 'g' );

set(plot_data_structure.button_handle_1, 'UserData',plot_data_structure);
set(plot_data_structure.slider_handle_1, 'UserData',plot_data_structure);
end

function [ mode_index_ ,point_index_ ] = find_closest_index(freq__, ph_vel__ , selected_freq , selected_pv,xlim_,ylim_)
for index = 1: size(freq__,2)
freq_norm_dist =  (freq__(:,index)-selected_freq) /(xlim_(2)*0.25) ;  % 0.25 is the aspect ratio of the dispersion figure
Vph_norm_dist  =  (ph_vel__(:,index)-selected_pv) /(ylim_(2))      ;
temp_norm_dist_from_mouse_pos =   sqrt(freq_norm_dist.^2 + Vph_norm_dist.^2);
[tosh,min_index] = min(abs(temp_norm_dist_from_mouse_pos));
min_index_v(index)        =     min_index;
norm_dist_vals(index)     =     temp_norm_dist_from_mouse_pos(min_index);
end % for index = 1: length(in_mode_index_list)
[tosh,min_dist_index] = min( abs(norm_dist_vals)) ;
mode_index_   =  min_dist_index                         ;
point_index_  =  min_index_v(min_dist_index)            ;
end %function


function node_positions  =   put_node_positions_in_3space(node_positions_old);
%  if only x and y then give a z position and set it to zero
if size(node_positions_old,2) == 2   % should be either 2 or 3
node_positions =  [node_positions_old, zeros(size(node_positions_old,1),1)];  
elseif size(node_positions_old,2) ==3
% do nothing as already in correct format    
node_positions =  node_positions_old;
else
node_positions = 'void'
disp('error node positions should be in either 2 or 3 d') 
end %if size(node_positions_old,2) ==2   % shoul be either 2 or 3    
end %function node_positions  =   put_node_positions_in_3space(mesh_.nd.pos);

function plot_a_mesh(node_positions, fig_handle , mesh_axis , element_nodes , color_ );
figure(fig_handle)
axes(mesh_axis)
axis equal
hold on
for index = 1:size(element_nodes ,1)  % go through each element
for index_2 = 1:size(element_nodes ,2)
temp(index_2,:) = [node_positions(element_nodes (index,index_2),1),node_positions(element_nodes (index,index_2),2),node_positions(element_nodes (index,index_2),3)];       
if index_2 == size(element_nodes ,2)
temp(index_2+1,:) = [node_positions(element_nodes (index,1),1),node_positions(element_nodes (index,1),2),node_positions(element_nodes (index,1),3)];       
end %if index == size(element_nodes ,1)    
end %for index_2 = 1:size(element_nodes ,2)
plot3(temp(:,1),temp(:,2),temp(:,3),color_);%'b:');
end %for index = 1:size(element_nodes ,1)
end

function deformed_node_positions = get_deformed_node_positions(undeformed_node_positions,ms_x,ms_y,ms_z,mult_factor)
del_x  = real(ms_x)*mult_factor;
del_y  = real(ms_y)*mult_factor;
del_z  = real(ms_z)*mult_factor;
deformed_node_positions   =   [undeformed_node_positions(:,1) + del_x , undeformed_node_positions(:,2) + del_y, undeformed_node_positions(:,3) + del_z];
end

function plot_dispersion_curves(freq,ph_vel, dispersion_axis,xlim_,ylim_,xlabel_,ylabel_)
cla(dispersion_axis)
axes(dispersion_axis)
plot(freq,ph_vel,'x-')
hold on
xlim(xlim_);
ylim(ylim_);
xlabel(xlabel_)
ylabel(ylabel_)
end
%----------------------------------------------------------------
%DONE improve the closest point function to look at closness to both freq and ph_vel
%DONE creat a seperate function for calculating the deformed shape
%DONE put a button in- if the button is pressed choose a position on the curve and then plot it
%DONE  --------------------------------
%DONE start off with the first point of the first mode
%DONE put in a callback button for choosing a point and plotting a mesh
%DONE values needed to plot the mesh   
%DONE --------------------------------
%DONE both axis aboject handles
%DONE the indices of the selected point-  this is set within the function
%DONE the undeformed mesh
%DONE all the x,y and z displacements
%DONE the  current magnification factor
%DONE --------------------------------
%DONE --------------------------------
%DONE first find the modes where the selected frequency is in range
%DONE then find the clsest mode within this subset
%DONE --------------------------------
%----------------------------------------------------------------