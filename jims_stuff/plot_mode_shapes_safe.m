function [output]  =  plot_mode_shapes_safe(mesh_,ms_x,ms_y,ms_z)

% take the data from  unsorted data initially
% plot the dispersion curves- then choose a location on the plot

%-----------------------------------------------------------------------
%
% given an x/y selected by ginput  find the closest points within the
% plotted data, do this for both sorted and unsorted data to conirm that
% they are the same
% 
%-----------------------------------------------------------------------
% function [output_args]  =  plot_mode_shapes_safe(mesh_)
% there is a problem with the mode shapes in data_wn-  make sure it matches
% with unsorted_results which seems to be correct
mult_factor_ = 5000;
x_disp = real(ms_x * mult_factor_); 
y_disp = real(ms_y * mult_factor_);   % for the moment
z_disp = real(ms_z * mult_factor_); 

%--------------------------------------------------------------------------------
%--------------------------------------------------------------------------------
% look at doing variable argument list - 1 argument - plot mesh_ only,  4
% arguments plt mesh_ with deformed mesh_
%--------------------------------------------------------------------------------
%--------------------------------------------------------------------------------
% this is for plotting the entire mesh_ at present
% start off by just plotting the real part of the displacement
%--------------------------------------------------------------------------------
% the mode shapes should be easily accesible from the structure using a
% single instance of index reference
% use data_wn at present
% choose a particular mode shape to plot-  just try plotting directly
% mode_shape
%--------------------------------------------------------------------------------
%--------------------------------------------------------------------------------

node_positions            =   put_node_positions_in_3space(mesh_.nd.pos)                                                        ;
deformed_node_positions   =   [node_positions(:,1) + x_disp , node_positions(:,2) + y_disp, node_positions(:,3) + z_disp]       ;
element_nodes   =   mesh_.el.nds ;


%view1 = [-37.5 30];
figure_handle =  figure(1);
axis auto;
axis equal;
zoom on;
hold on
%view(view1)

plot_a_mesh(node_positions,element_nodes,figure_handle,'r') ;

plot_a_mesh(deformed_node_positions,element_nodes,figure_handle,'g') ;

output.x_disp = x_disp;
output.y_disp = y_disp;
output.z_disp = z_disp;

end %  of main function 
%-----------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------
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


function plot_a_mesh(node_positions,element_nodes,figure_handle,color_) ;

figure(figure_handle)

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




% alternatively:
% -----------------------------------------
% figure;
% subplot(2,1,1)
% fv.Vertices = mesh_.nd.pos;
% fv.Faces = mesh_.el.nds;
% patch(fv, 'FaceColor', 'c');
% axis equal;
% axis off;
 %function
