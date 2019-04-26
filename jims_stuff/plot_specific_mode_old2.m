function [aa] =   plot_specific_mode_(reshaped_proc_data);
%  --------------------------------
% start off with the first point of the first mode
% put in a callback button for choosing a point and plotting a mesh
%  values needed to plot the mesh   
%  --------------------------------
%  both axis aboject handles
%  the indices of the selected point-  this is set within the function
%  the undeformed mesh
%  all the x,y and z displacements
%  the  current magnification factor
%  --------------------------------
%  --------------------------------
%  first find the modes where the selected frequency is in range
%  then find the clsest mode within this subset
%  --------------------------------


plot_data_structure.undeformed_node_positions    =   put_node_positions_in_3space(reshaped_proc_data.mesh.nd.pos)   ;
plot_data_structure.element_nodes                =   reshaped_proc_data.mesh.el.nds                                 ;
plot_data_structure.mult_factor                  =   50000                                                         ;
plot_data_structure.fig_handle                   =   figure(1)                                                      ;
plot_data_structure.dispersion_axis              =   subplot(2,1,1)                                                 ;
plot_data_structure.mesh_axis                    =   subplot(2,1,2)                                                 ;  
plot_data_structure.continue_                    =  1 ;

axis auto;
axis equal;
zoom on;

axes(plot_data_structure.dispersion_axis  )
plot(reshaped_proc_data.freq,reshaped_proc_data.ph_vel)
hold on
xlim([0 , 0.15E5]);
ylim([0 , 10000]);
xlabel('Freq(Hz)')
ylabel('Phase Velocity(m/s)')


plot_a_mesh(plot_data_structure.undeformed_node_positions , plot_data_structure.element_nodes , plot_data_structure.fig_handle, plot_data_structure.mesh_axis   ,'r') ;
continue_ = 1;

while continue_ == 1
    
%button_handle_1 = uicontrol('Style', 'pushbutton', 'String', 'Choose point','Position', [100 100 100 20],'Callback',@but_func_1);       
%set(button_handle_1, 'UserData',plot_data_structure)

axes(plot_data_structure.dispersion_axis );
hold on
[selected_freq,slected_pv, button_] = ginput(1);
[mode_index_ ,point_index_] = find_closest_index(reshaped_proc_data.freq, reshaped_proc_data.ph_vel , selected_freq , slected_pv);
plot(reshaped_proc_data.freq(point_index_,mode_index_) ,reshaped_proc_data.ph_vel(point_index_,mode_index_), 'x', 'markersize',10)
title(['Current mode selected: Mode ',num2str(mode_index_) ,', Point ',num2str(point_index_) ],'FontSize',18) 

cla(plot_data_structure.mesh_axis  )
plot_a_mesh(plot_data_structure.undeformed_node_positions , plot_data_structure.element_nodes , plot_data_structure.fig_handle, plot_data_structure.mesh_axis   ,'r') ;

del_x = real(reshaped_proc_data.ms_x(:,point_index_,mode_index_)*plot_data_structure.mult_factor) ;
del_y = real(reshaped_proc_data.ms_y(:,point_index_,mode_index_)*plot_data_structure.mult_factor) ;
del_z = real(reshaped_proc_data.ms_z(:,point_index_,mode_index_)*plot_data_structure.mult_factor) ;

deformed_node_positions   =   [plot_data_structure.undeformed_node_positions(:,1) + del_x , plot_data_structure.undeformed_node_positions(:,2) + del_y, plot_data_structure.undeformed_node_positions(:,3) + del_z];
plot_a_mesh(deformed_node_positions , plot_data_structure.element_nodes , plot_data_structure.fig_handle,plot_data_structure.mesh_axis,'g');

%aa = uicontrol('Style', 'slider', 'Min',1,'Max',10000,'Value',1000,'Position',[20 20 120 20],'Callback',@sliderCallback);

if(button_==3)
continue_ = 0 ;     
end %if(button_==3)

end %while continue_ == 1

% plot the mode in the reshaped data and the equivalent one in the
% unsorted_results -  just to validate thet the mode is correct
% have an option to adjust the multiplication factor

end %function plot_specific_mode_(reshaped_proc_data )

function  but_func_1(hObject, evt)
disp(['Selecting a point'])


end


function [ mode_index_ ,point_index_ ] = find_closest_index(freq__, ph_vel__ , selected_freq , selected_pv)
in_freq_count = 0;
%for index = 1 : size(freq__,1)
for index = 1 : size(freq__,2)
%if  min(freq__(index,:))  < selected_freq && max(freq__(index,:)) > selected_freq
if  min(freq__(:,index))  < selected_freq && max(freq__(:,index)) > selected_freq    
    in_freq_count = in_freq_count + 1;
    in_mode_index_list(in_freq_count) = index;   
     end %if  min(reshaped_proc_data.freq(1,:))  < selected_freq && max(reshaped_proc_data.freq(1,:)) > selected_freq
end %for index = 1 : size(reshaped_proc_data.freq,1)

%disp([num2str(in_freq_count),' modes with frequency range found '])

for index = 1: length(in_mode_index_list)
% for each mode find the index of the clostest freq

temp_frqs =  freq__(:,in_mode_index_list(index))-selected_freq ;     
[junk,min_index] = min(abs(temp_frqs));

min_index_v(index)   = min_index;
ph_vel_vals(index)   = ph_vel__(min_index,in_mode_index_list(index));
end % for index = 1: length(in_mode_index_list)
[junk,min_ph_index] = min( abs(ph_vel_vals - selected_pv)) ;

%min_ph_index
%size(in_mode_index_list)

mode_index_   =  in_mode_index_list(min_ph_index)     ;
point_index_  =  min_index_v(min_ph_index)            ;


%disp([num2str(mode_index_ ),' , ',num2str(point_index_)]); 

% go through each 'in' mode and find the index of the closest frequency
% then find the minimum of the of these indices in ph_vel to find the
% closest indes for freq/ph_vel

closest_index_ = 'void';

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


function plot_a_mesh(node_positions,element_nodes,figure_handle,axis_handle,color_) ;

figure(figure_handle)
axes(axis_handle)
hold on

for index = 1:size(element_nodes,1)  % go through each element
for index_2 = 1:size(element_nodes,2)
    
temp(index_2,:) = [node_positions(element_nodes(index,index_2),1),node_positions(element_nodes(index,index_2),2),node_positions(element_nodes(index,index_2),3)];       

if index_2 == size(element_nodes,2)
temp(index_2+1,:) = [node_positions(element_nodes(index,1),1),node_positions(element_nodes(index,1),2),node_positions(element_nodes(index,1),3)];       
end %if index == size(element_nodes,1)    

end %for index_2 = 1:size(element_nodes,2)
plot3(temp(:,1),temp(:,2),temp(:,3),color_);%'b:');
end %for index = 1:size(element_nodes,1)

end
